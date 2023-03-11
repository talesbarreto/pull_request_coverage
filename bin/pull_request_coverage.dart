import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:file/local.dart';
import 'package:pull_request_coverage/src/data/io/repository/io_repository_impl.dart';
import 'package:pull_request_coverage/src/data/user_options/user_options_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/analyser/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/get_exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/set_uncoverd_lines_on_file_diff.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/should_analyse_this_file.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/remove_git_root_relative_path.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncoverd_file_lines.dart';
import 'package:pull_request_coverage/src/domain/io/use_case/read_line_from_stdin.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/cli_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/markdown_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_result_for_file.dart';

UserOptions _getOrFailUserOptions(List<String> arguments) {
  final UserOptionsRepository argsRepository = UserOptionsRepositoryImpl(ArgParser());
  final userOptions = argsRepository.getUserOptions(arguments);
  if (userOptions is ResultSuccess<UserOptions>) {
    return userOptions.data;
  } else {
    userOptions as ResultError<UserOptions>;
    print("Error parsing params: ${userOptions.message}");
    exit(ExitCode.error);
  }
}

Future<List<String>> _getOrFailLcovLines(String filePath) async {
  try {
    final lines = await File(filePath).readAsLines();
    return lines;
  } catch (e) {
    print("Error reading lcov.info file: $e");
    print("\tDid you run `flutter test --coverage`?");
    exit(ExitCode.error);
  }
}

OutputGenerator _getOutputGenerator(UserOptions userOptions, ColorizeCliText colorizeText) {
  switch (userOptions.outputMode) {
    case OutputMode.cli:
      return CliOutputGenerator(
        colorizeText: colorizeText,
        userOptions: userOptions,
      );
    case OutputMode.markdown:
      return MarkdownOutputGenerator(
        userOptions: userOptions,
      );
  }
}

Future<void> main(List<String> arguments) async {
  final ioRepository = IoRepositoryImpl(LocalFileSystem(),stdin);

  final userOptions = _getOrFailUserOptions(arguments);
  final lcovLines = await _getOrFailLcovLines(userOptions.lcovFilePath);
  final colorizeText = ColorizeCliText(userOptions.useColorfulOutput);
  final outputGenerator = _getOutputGenerator(userOptions, colorizeText);

  final analyzeUseCase = Analyze(
    parseGitDiff: ParseGitDiff(RemoveGitRootRelativePath(await ioRepository.getGitRootRelativePath())),
    forEachFileOnGitDiff: ForEachFileOnGitDiff(ReadLineFromStdin(ioRepository).call),
    lcovLines: lcovLines,
    shouldAnalyseThisFile: ShouldAnalyseThisFile(userOptions),
    setUncoveredLines: SetUncoveredLinesOnFileDiff(),
    getUncoveredFileLines: GetUncoveredFileLines(),
    printResultForFile: PrintResultForFile(
      print: print,
      outputGenerator: outputGenerator,
      showUncoveredLines: userOptions.showUncoveredCode,
    ),
  );

  final result = await analyzeUseCase();

  print(outputGenerator.getReport(result, userOptions.minimumCoverageRate, userOptions.maximumUncoveredLines));

  exit(GetExitCode()(result, userOptions));
}
