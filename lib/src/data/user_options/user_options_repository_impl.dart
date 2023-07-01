import 'package:file/file.dart';
import 'package:glob/glob.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/arg_data_source.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/yaml_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_options_args.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';

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
    final yamlConfig = UserOptionsArgs.yamlConfigFilePath;
    final yamlFilePath = argDataSource.getString(yamlConfig) ?? yamlConfig.defaultValue;
    final yamlFile = fileSystem.file(yamlFilePath);
    if (yamlFile.existsSync()) {
      yamlDataSource.parse(yamlFile.readAsStringSync());
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

  @override
  Result<UserOptions> getUserOptions(List<String> arguments) {
    final arg = argGetters;
    try {
      _setArgGetters(arguments);
      final excludesFileList = arg.getStringList(UserOptionsArgs.ignore);

      return ResultSuccess(
        UserOptions(
          ignoredFiles: (excludesFileList != null) ? _parseGlob(excludesFileList) : [],
          lcovFilePath: arg.getString(UserOptionsArgs.lcovFile) ?? UserOptionsArgs.lcovFile.defaultValue,
          minimumCoverageRate: arg.getDouble(UserOptionsArgs.minimumCoverage),
          maximumUncoveredLines: arg.getInt(UserOptionsArgs.maximumUncoveredLines),
          showUncoveredCode: arg.getBooleanOrDefault(UserOptionsArgs.showUncoveredCode),
          useColorfulOutput: arg.getBooleanOrDefault(UserOptionsArgs.useColorfulOutput),
          reportFullyCoveredFiles: arg.getBooleanOrDefault(UserOptionsArgs.reportFullyCoveredFiles),
          outputMode: arg.getString(UserOptionsArgs.outputMode) == "markdown" ? OutputMode.markdown : OutputMode.cli,
          fractionalDigits: arg.getInt(UserOptionsArgs.fractionDigits) ?? 2,
          markdownMode: arg.getString(UserOptionsArgs.markdownMode) == "dart" ? MarkdownMode.dart : MarkdownMode.diff,
          fullyTestedMessage: arg.getString(UserOptionsArgs.fullyTestedMessage),
          stdinTimeout: Duration(seconds: arg.getInt(UserOptionsArgs.stdinTimeout) ?? 1),
          deprecatedFilterSet: false,
          lineFilters: _parseRegex(arg.getStringList(UserOptionsArgs.ignoreLines)),
          ignoreKnownGeneratedFiles: arg.getBooleanOrDefault(UserOptionsArgs.excludeKnownGeneratedFiles),
          knownGeneratedFiles: [
            ..._parseGlob(arg.getStringList(UserOptionsArgs.knownGeneratedFiles) ??
                UserOptionsArgs.knownGeneratedFiles.defaultValue),
            ..._parseGlob(arg.getStringList(UserOptionsArgs.addToKnownGeneratedFiles) ?? []),
          ],
          useEmojis: arg.getBooleanOrDefault(UserOptionsArgs.printEmojis),
        ),
      );
    } catch (e, s) {
      return ResultError(e.toString(), e, s);
    }
  }
}
