import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/arg_data_source.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/yaml_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/approval_requirement.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_option_register.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';
import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

import 'data_source/options_getters.dart';

class UserOptionsRepositoryImpl implements UserOptionsRepository {
  final FileSystem fileSystem;
  final OptionsGetters argGetters;
  final ArgDataSource argDataSource;
  final YamlDataSource yamlDataSource;

  const UserOptionsRepositoryImpl({
    required this.argDataSource,
    required this.yamlDataSource,
    required this.argGetters,
    required this.fileSystem,
  });

  List<Glob> _parseGlob(List<String> patterns) {
    try {
      return List.generate(patterns.length, (index) => Glob(patterns[index]), growable: false);
    } catch (e) {
      throw Exception("Glob parser error: $e");
    }
  }

  void _setArgGetters(List<String> arguments) {
    argDataSource.parse(arguments);
    final yamlConfig = UserOptionRegister.yamlConfigFilePath;
    final yamlFilePath = argDataSource.getString(yamlConfig) ?? yamlConfig.defaultValue;
    final yamlFile = fileSystem.file(yamlFilePath);
    if (yamlFile.existsSync()) {
      yamlDataSource.parse(yamlFile.readAsStringSync());
      yamlDataSource.throwExceptionOnInvalidUserOption(UserOptionRegister.getValidOptions());
      argGetters.setDataSources([argDataSource, yamlDataSource]);
    } else {
      argGetters.setDataSources([argDataSource]);
    }
  }

  List<RegExp> _parseRegex(List<String>? expressions) {
    return expressions?.map(
          (expression) {
            try {
              return RegExp(expression);
            } catch (e) {
              throw Exception("Fail to parse regex `$expression` : $e");
            }
          },
        ).toList(growable: false) ??
        const [];
  }

  LogLevel _parseLogLevel(String? text) {
    switch (text) {
      case "error":
        return LogLevel.error;
      case "warning":
        return LogLevel.warning;
      case "info":
        return LogLevel.info;
      case "verbose":
        return LogLevel.verbose;
      case "none":
      default:
        return LogLevel.none;
    }
  }

  ApprovalRequirement _parseApprovalRequirement(String? string) {
    switch (string) {
      case "lines-or-rate":
        return ApprovalRequirement.linesOrRate;
      case "lines-and-rate":
      default:
        return ApprovalRequirement.linesAndRate;
    }
  }

  @override
  Result<UserOptions> getUserOptions(List<String> arguments) {
    final arg = argGetters;
    try {
      _setArgGetters(arguments);
      final excludesFileList = arg.getStringList(UserOptionRegister.ignore);

      return ResultSuccess(
        UserOptions(
          ignoredFiles: (excludesFileList != null) ? _parseGlob(excludesFileList) : [],
          lcovFilePath: arg.getString(UserOptionRegister.lcovFile) ?? UserOptionRegister.lcovFile.defaultValue,
          minimumCoverageRate: arg.getDouble(UserOptionRegister.minimumCoverage),
          maximumUncoveredLines: arg.getInt(UserOptionRegister.maximumUncoveredLines),
          showUncoveredCode: arg.getBooleanOrDefault(UserOptionRegister.showUncoveredCode),
          useColorfulOutput: arg.getBooleanOrDefault(UserOptionRegister.useColorfulOutput),
          reportFullyCoveredFiles: arg.getBooleanOrDefault(UserOptionRegister.reportFullyCoveredFiles),
          outputMode: arg.getString(UserOptionRegister.outputMode) == "markdown" ? OutputMode.markdown : OutputMode.cli,
          fractionalDigits: arg.getInt(UserOptionRegister.fractionDigits) ?? 2,
          markdownMode:
              arg.getString(UserOptionRegister.markdownMode) == "dart" ? MarkdownMode.dart : MarkdownMode.diff,
          fullyTestedMessage: arg.getString(UserOptionRegister.fullyTestedMessage),
          stdinTimeout: Duration(seconds: arg.getInt(UserOptionRegister.stdinTimeout) ?? 1),
          deprecatedFilterSet: false,
          lineFilters: _parseRegex(arg.getStringList(UserOptionRegister.ignoreLines)),
          ignoreKnownGeneratedFiles: arg.getBooleanOrDefault(UserOptionRegister.excludeKnownGeneratedFiles),
          knownGeneratedFiles: [
            ..._parseGlob(arg.getStringList(UserOptionRegister.knownGeneratedFiles) ??
                UserOptionRegister.knownGeneratedFiles.defaultValue),
            ..._parseGlob(arg.getStringList(UserOptionRegister.addToKnownGeneratedFiles) ?? []),
          ],
          useEmojis: arg.getBooleanOrDefault(UserOptionRegister.printEmojis),
          approvalRequirement: _parseApprovalRequirement(arg.getString(UserOptionRegister.approvalRequirement)),
          logLevel: _parseLogLevel(arg.getString(UserOptionRegister.logLevel)),
        ),
      );
    } catch (e, s) {
      return ResultError(e.toString(), e, s);
    }
  }
}
