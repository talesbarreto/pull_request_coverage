import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:pull_request_coverage/src/data/user_options/user_options_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/analyser/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/get_exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/set_uncoverd_lines_on_file_diff.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/should_analyse_this_file.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/convert_file_diff_from_git_diff_to_file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncoverd_file_lines.dart';
import 'package:pull_request_coverage/src/domain/presentation/use_case/print_analyze_result.dart';
import 'package:pull_request_coverage/src/domain/presentation/use_case/print_result_for_file.dart';
import 'package:pull_request_coverage/src/domain/stdin_reader/use_case/read_line_from_stdin.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';

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

Future<List<String>> _getOrFailLcovLines(String filePath) {
  try {
    return File(filePath).readAsLines();
  } catch (e) {
    print("Error reading lcov.info file: $e");
    exit(ExitCode.error);
  }
}

Future<void> main(List<String> arguments) async {
  final userOptions = _getOrFailUserOptions(arguments);
  final lcovLines = await _getOrFailLcovLines(userOptions.lcovFilePath);

  final analyzeUseCase = Analyze(
    convertFileDiffFromGitDiffToFileDiff: ConvertFileDiffFromGitDiffToFileDiff(),
    forEachFileOnGitDiff: ForEachFileOnGitDiff(ReadLineFromStdin().call),
    lcovLines: lcovLines,
    shouldAnalyseThisFile: ShouldAnalyseThisFile(userOptions),
    setUncoveredLines: SetUncoveredLinesOnFileDiff(),
    getUncoveredFileLines: GetUncoveredFileLines(),
    printResultForFile: PrintResultForFile(print),
    shouldPrintResultsForEachFile: !userOptions.hideUncoveredLines,
  );

  final result = await analyzeUseCase();

  PrintAnalysisResult(print)(result, userOptions);

  exit(GetExitCode()(result, userOptions));
}
