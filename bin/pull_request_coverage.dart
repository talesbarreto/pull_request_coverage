import 'dart:async';
import 'dart:io';
import 'package:file/local.dart';
import 'package:pull_request_coverage/src/di/analyze_module.dart';
import 'package:pull_request_coverage/src/di/io_module.dart';
import 'package:pull_request_coverage/src/di/output_generator_module.dart';
import 'package:pull_request_coverage/src/di/user_options_module.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_exit_code.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/use_case/get_or_fail_user_options.dart';
import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';
import 'package:pull_request_coverage/src/presentation/logger/logger.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_warnings_for_unexpected_file_structure.dart';

Future<void> main(List<String> arguments) async {
  final fileSystem = LocalFileSystem();
  final userOptions = GetOrFailUserOptions(
    userOptionsRepository: UserOptionsModule.provideUserOptionsRepository(fileSystem: fileSystem),
  ).call(arguments);

  final ioRepository = IoModule.provideIoRepository(stdinTimeout: userOptions.stdinTimeout, fileSystem: fileSystem);
  final gitRootRelativePath = await ioRepository.getGitRootRelativePath();
  final colorizeText = ColorizeCliText(userOptions.useColorfulOutput && userOptions.outputMode == OutputMode.cli);
  final outputGenerator = OutputGeneratorModule.providePlainTextOutputGenerator(userOptions);
  final getOrFailLcovLines = IoModule.provideGetOrFailLcovLines();
  final logger = Logger(colorizeCliText: colorizeText,logLevel: LogLevel.warning);
  Logger.setGlobalLogger(logger);

  PrintWarningsForUnexpectedFileStructure(print, colorizeText, logger)(
    gitRootRelativePath: gitRootRelativePath,
    isLibDirPresent: await ioRepository.doesLibDirectoryExist(),
  );

  final lcovLines = await getOrFailLcovLines(userOptions.lcovFilePath, fileSystem);

  final analyzeUseCase = await AnalyzeModule.provideAnalyzeUseCase(
    userOptions: userOptions,
    lcovLines: lcovLines,
    ioRepository: ioRepository,
    outputGenerator: outputGenerator,
  );

  final result = await analyzeUseCase();

  exit(GetExitCode()(result, userOptions));
}
