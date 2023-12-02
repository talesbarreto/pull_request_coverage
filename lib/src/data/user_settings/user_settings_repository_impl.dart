import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:pull_request_coverage/src/data/user_settings/data_source/arg_data_source.dart';
import 'package:pull_request_coverage/src/data/user_settings/data_source/yaml_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/approval_requirement.dart';
import 'package:pull_request_coverage/src/domain/user_settings/user_settings_register.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
import 'package:pull_request_coverage/src/domain/user_settings/repositories/user_settings_repository.dart';
import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

import 'data_source/settings_getters.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final FileSystem fileSystem;
  final SettingsGetters argGetters;
  final ArgDataSource argDataSource;
  final YamlDataSource yamlDataSource;

  const UserSettingsRepositoryImpl({
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
    final yamlConfig = UserSettingsRegister.yamlConfigFilePath;
    final yamlFilePath = argDataSource.getString(yamlConfig) ?? yamlConfig.defaultValue;
    final yamlFile = fileSystem.file(yamlFilePath);
    if (yamlFile.existsSync()) {
      yamlDataSource.parse(yamlFile.readAsStringSync());
      yamlDataSource.throwExceptionOnInvalidUserSettings(UserSettingsRegister.getValidOptions());
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
  Result<UserSettings> getUserSettings(List<String> arguments) {
    final arg = argGetters;
    try {
      _setArgGetters(arguments);
      final excludesFileList = arg.getStringList(UserSettingsRegister.ignore);

      return ResultSuccess(
        UserSettings(
          ignoredFiles: (excludesFileList != null) ? _parseGlob(excludesFileList) : [],
          lcovFilePath: arg.getString(UserSettingsRegister.lcovFile) ?? UserSettingsRegister.lcovFile.defaultValue,
          minimumCoverageRate: arg.getDouble(UserSettingsRegister.minimumCoverage),
          maximumUncoveredLines: arg.getInt(UserSettingsRegister.maximumUncoveredLines),
          showUncoveredCode: arg.getBooleanOrDefault(UserSettingsRegister.showUncoveredCode),
          useColorfulOutput: arg.getBooleanOrDefault(UserSettingsRegister.useColorfulOutput),
          reportFullyCoveredFiles: arg.getBooleanOrDefault(UserSettingsRegister.reportFullyCoveredFiles),
          outputMode: arg.getString(UserSettingsRegister.outputMode) == "markdown" ? OutputMode.markdown : OutputMode.cli,
          fractionalDigits: arg.getInt(UserSettingsRegister.fractionDigits) ?? 2,
          markdownMode:
              arg.getString(UserSettingsRegister.markdownMode) == "dart" ? MarkdownMode.dart : MarkdownMode.diff,
          fullyTestedMessage: arg.getString(UserSettingsRegister.fullyTestedMessage),
          stdinTimeout: Duration(seconds: arg.getInt(UserSettingsRegister.stdinTimeout) ?? 1),
          deprecatedFilterSet: false,
          lineFilters: _parseRegex(arg.getStringList(UserSettingsRegister.ignoreLines)),
          ignoreKnownGeneratedFiles: arg.getBooleanOrDefault(UserSettingsRegister.excludeKnownGeneratedFiles),
          knownGeneratedFiles: [
            ..._parseGlob(arg.getStringList(UserSettingsRegister.knownGeneratedFiles) ??
                UserSettingsRegister.knownGeneratedFiles.defaultValue),
            ..._parseGlob(arg.getStringList(UserSettingsRegister.addToKnownGeneratedFiles) ?? []),
          ],
          useEmojis: arg.getBooleanOrDefault(UserSettingsRegister.printEmojis),
          approvalRequirement: _parseApprovalRequirement(arg.getString(UserSettingsRegister.approvalRequirement)),
          logLevel: _parseLogLevel(arg.getString(UserSettingsRegister.logLevel)),
        ),
      );
    } catch (e, s) {
      return ResultError(e.toString(), e, s);
    }
  }
}
