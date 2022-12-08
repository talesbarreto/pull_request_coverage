import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/set_uncoverd_lines_on_file_diff.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/should_analyse_this_file.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_hub_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncoverd_file_lines.dart';
import 'package:pull_request_coverage/src/domain/presentation/use_case/print_result_for_file.dart';

/// [Analyze] is the main use case of the application.
class Analyze {
  final ParseGitDiff parseGitDiff;
  final ForEachFileOnGitDiff forEachFileOnGitDiff;
  final ShouldAnalyseThisFile shouldAnalyseThisFile;
  final SetUncoveredLinesOnFileDiff setUncoveredLines;
  final GetUncoveredFileLines getUncoveredFileLines;
  final PrintResultForFile printResultForFile;
  final List<String> lcovLines;

  const Analyze({
    required this.parseGitDiff,
    required this.forEachFileOnGitDiff,
    required this.lcovLines,
    required this.shouldAnalyseThisFile,
    required this.setUncoveredLines,
    required this.getUncoveredFileLines,
    required this.printResultForFile,
  });

  Future<AnalysisResult> call() async {
    int newLines = 0;
    int uncoveredLines = 0;

    await forEachFileOnGitDiff((List<String> fileLines) {
      final FileDiff? fileDiff = parseGitDiff(fileLines);
      if (fileDiff != null && shouldAnalyseThisFile(fileDiff.path)) {
        final uncoveredLinesOnFile = getUncoveredFileLines(lcovLines, fileDiff.path);
        if (uncoveredLinesOnFile != null) {
          setUncoveredLines(fileDiff, uncoveredLinesOnFile);
          newLines += fileDiff.lines.where((element) => element.isANewLine).length;
          uncoveredLines += fileDiff.lines.where((element) => element.isAnUncoveredNewLine).length;
        }
        printResultForFile(fileDiff);
      }
    });
    return AnalysisResult(
      totalOfNewLines: newLines,
      totalOfUncoveredNewLines: uncoveredLines,
    );
  }
}
