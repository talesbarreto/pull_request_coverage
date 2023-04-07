import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_file_from_project.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_generated_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_an_ignored_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncovered_file_lines.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';

/// [Analyze] is the main use case of the application.
class Analyze {
  final ParseGitDiff parseGitDiff;
  final ForEachFileOnGitDiff forEachFileOnGitDiff;
  final IsAGeneratedFile isAGeneratedFile;
  final IsAnIgnoredFile isAnIgnoredFile;
  final SetFileLineResultData setUncoveredLines;
  final GetUncoveredFileLines getUncoveredFileLines;
  final IsAFileFromProject isAFileFromProject;
  final OutputGenerator outputGenerator;
  final List<String> lcovLines;

  const Analyze({
    required this.parseGitDiff,
    required this.forEachFileOnGitDiff,
    required this.lcovLines,
    required this.isAGeneratedFile,
    required this.isAnIgnoredFile,
    required this.setUncoveredLines,
    required this.getUncoveredFileLines,
    required this.outputGenerator,
    required this.isAFileFromProject,
  });

  Future<AnalysisResult> call() async {
    int newLines = 0;
    int uncoveredLines = 0;
    int untestedIgnoredLines = 0;

    await forEachFileOnGitDiff((List<String> fileLines) {
      final FileDiff? fileDiff = parseGitDiff(fileLines);
      if (fileDiff != null && isAFileFromProject(fileDiff.path) && !isAGeneratedFile(fileDiff.path)) {
        final ignoreFile = isAnIgnoredFile(fileDiff.path);
        final uncoveredLinesOnFile = getUncoveredFileLines(lcovLines, fileDiff.path);
        if (uncoveredLinesOnFile != null) {
          setUncoveredLines(fileDiff, uncoveredLinesOnFile);
          if (!ignoreFile) {
            newLines += fileDiff.lines.where((element) => element.isANewNotIgnoredLine).length;
            uncoveredLines += fileDiff.lines.where((element) => element.isTestMissing).length;
          }
          untestedIgnoredLines += fileDiff.lines.where((element) {
            return element.isANewLine == true && element.isUntested == true && (element.ignored == true || ignoreFile);
          }).length;
        }

        outputGenerator.addFile(fileDiff);
      }
    });
    final result = AnalysisResult(
      linesShouldBeTested: newLines,
      linesMissingTests: uncoveredLines,
      untestedIgnoredLines: untestedIgnoredLines,
    );

    outputGenerator.setReport(result);
    outputGenerator.printOutput();
    return result;
  }
}
