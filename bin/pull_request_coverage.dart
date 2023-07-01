import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file/local.dart';
import 'package:pull_request_coverage/src/di/analyze_module.dart';
import 'package:pull_request_coverage/src/di/file_module.dart';
import 'package:pull_request_coverage/src/di/output_generator_module.dart';
import 'package:pull_request_coverage/src/di/user_options_module.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_file_report_from_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/files_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/presentation/logger/logger.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_warnings_for_unexpected_file_structure.dart';

Future<void> main(List<String> arguments) async {
  final fileSystem = LocalFileSystem();
  final userOptions = UserOptionsModule.provideUserOptions(arguments: arguments, fileSystem: fileSystem);
  final ioRepository = IoModule.provideIoRepository(stdinTimeout: userOptions.stdinTimeout, fileSystem: fileSystem);

  final colorizeText = ColorizeText(
    useColorfulOutput: userOptions.useColorfulOutput && userOptions.outputMode == OutputMode.cli,
  );

  Logger.setGlobalLogger(Logger(logLevel: userOptions.logLevel));

  final gitRootRelativePath = await ioRepository.getGitRootRelativePath();
  PrintWarningsForUnexpectedFileStructure(print, colorizeText, logger)(
    gitRootRelativePath: gitRootRelativePath,
    isLibDirPresent: await ioRepository.doesLibDirectoryExist(),
  );

  final getOrFailLcovLines = IoModule.provideGetOrFailLcovLines();
  final lcovLines = await getOrFailLcovLines(userOptions.lcovFilePath, fileSystem);

  final onFilesOnGitDiff = OnFilesOnGitDiff(stdin.transform(utf8.decoder).transform<String>(const LineSplitter()))();

  final analyze = await AnalyzeModule.provideAnalyzeUseCase(
    userOptions: userOptions,
    lcovLines: lcovLines,
    ioRepository: ioRepository,
    getFileReportFromDiff: GetFileReportFromDiff(),
    onFilesOnGitDiff: onFilesOnGitDiff,
  );

  final outputGenerator = OutputGeneratorModule.provideGenerator(
    userOptions: userOptions,
    colorizeText: colorizeText,
  );

  await for (final result in analyze()) {
    result.when(
      isFileReport: (data) {
        outputGenerator.addFileReport(data);
      },
      isAnalysisResult: (data) {
        outputGenerator.terminate(data);
        exit(GetExitCode()(data, userOptions));
      },
    );
  }
}
