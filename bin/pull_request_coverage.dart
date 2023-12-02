import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:pull_request_coverage/src/di/analyze_module.dart';
import 'package:pull_request_coverage/src/di/file_module.dart';
import 'package:pull_request_coverage/src/di/output_generator_module.dart';
import 'package:pull_request_coverage/src/di/user_settings_module.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_file_report_from_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/get_files_oon_git_diff_stream.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
import 'package:pull_request_coverage/src/presentation/logger/logger.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_warnings_for_unexpected_file_structure.dart';

UserSettings _getOrFailUserSettings(
  FileSystem fileSystem,
  List<String> arguments,
) {
  final getOrFail = UserSettingsModule.provideGetOrFailUserSettings(fileSystem: fileSystem);
  return getOrFail(arguments);
}

ColorizeText _getColorizeText(UserSettings userSettings) {
  final useColorfulOutput = userSettings.useColorfulOutput && userSettings.outputMode == OutputMode.cli;
  return ColorizeText(useColorfulOutput: useColorfulOutput);
}

Future<void> main(List<String> arguments) async {
  final fileSystem = LocalFileSystem();

  final userSettings = _getOrFailUserSettings(fileSystem, arguments);

  Logger.setGlobalLogger(Logger(logLevel: userSettings.logLevel));

  final fileRepository = IoModule.provideFileRepository(
    stdinTimeout: userSettings.stdinTimeout,
    fileSystem: fileSystem,
  );

  final colorizeText = _getColorizeText(userSettings);

  Logger.setGlobalLogger(Logger(logLevel: userSettings.logLevel));

  // finds where `.git` file is located
  final gitRootRelativePath = await fileRepository.getGitRootRelativePath();

  PrintWarningsForUnexpectedFileStructure(print, colorizeText, logger).call(
    gitRootRelativePath: gitRootRelativePath,
    isLibDirPresent: await fileRepository.doesLibDirectoryExist(),
  );

  final getOrFailLcovLines = IoModule.provideGetOrFailLcovLines();

  final lcovLines = await getOrFailLcovLines(userSettings.lcovFilePath, fileSystem);

  final stdinStream = stdin.transform(utf8.decoder).transform<String>(const LineSplitter());

  final filesOnGitDiffStream = GetFilesOnGitDiffStream(stdinStream).call();

  final analyze = await AnalyzeModule.provideAnalyzeUseCase(
    userSettings: userSettings,
    lcovLines: lcovLines,
    ioRepository: fileRepository,
    getFileReportFromDiff: GetFileReportFromDiff(),
    filesOnGitDiffStream: filesOnGitDiffStream,
  );

  final outputGenerator = OutputGeneratorModule.provideGenerator(
    userSettings: userSettings,
    colorizeText: colorizeText,
  );

  await for (final result in analyze()) {
    result.when(
      isFileReport: (data) {
        outputGenerator.addFileReport(data);
      },
      isAnalysisResult: (data) {
        outputGenerator.terminate(data);
        exit(GetExitCode()(data, userSettings));
      },
    );
  }
}
