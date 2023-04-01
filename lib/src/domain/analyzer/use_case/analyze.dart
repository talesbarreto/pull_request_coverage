import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_file_from_project.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/should_analyze_this_file.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncoverd_file_lines.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_result_for_file.dart';

/// [Analyze] is the main use case of the application.
class Analyze {
  final ParseGitDiff parseGitDiff;
  final ForEachFileOnGitDiff forEachFileOnGitDiff;
  final ShouldAnalyzeThisFile shouldAnalyzeThisFile;
  final SetFileLineResultData setUncoveredLines;
  final GetUncoveredFileLines getUncoveredFileLines;
  final IsAFileFromProject isAFileFromProject;
  final PrintResultForFile printResultForFile;
  final List<String> lcovLines;

  const Analyze({
    required this.parseGitDiff,
    required this.forEachFileOnGitDiff,
    required this.lcovLines,
    required this.shouldAnalyzeThisFile,
    required this.setUncoveredLines,
    required this.getUncoveredFileLines,
    required this.printResultForFile,
    required this.isAFileFromProject,
  });

  Future<AnalysisResult> call() async {
    int newLines = 0;
    int uncoveredLines = 0;
    int ignoredMissingTest = 0;

    await forEachFileOnGitDiff((List<String> fileLines) {
      final FileDiff? fileDiff = parseGitDiff(fileLines);
      if (fileDiff != null && isAFileFromProject(fileDiff.path)) {
        final ignoreFile = !shouldAnalyzeThisFile(fileDiff.path);
        final uncoveredLinesOnFile = getUncoveredFileLines(lcovLines, fileDiff.path);
        if (uncoveredLinesOnFile != null) {
          setUncoveredLines(fileDiff, uncoveredLinesOnFile);
          if (!ignoreFile) {
            newLines += fileDiff.lines.where((element) => element.isANewNotIgnoredLine).length;
            uncoveredLines += fileDiff.lines.where((element) => element.isTestMissing).length;
          }
          ignoredMissingTest += fileDiff.lines.where((element) {
            return element.isANewLine == true && element.isUncovered == true && element.ignored == true;
          }).length;
        }
        if (!ignoreFile) {
          printResultForFile(fileDiff);
        }
      }
    });
    return AnalysisResult(
      totalOfNewLines: newLines,
      totalOfUncoveredNewLines: uncoveredLines,
      totalOfIgnoredLinesMissingTests: ignoredMissingTest,
    );
  }
}
