import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/report.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_file_report_from_diff.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_generated_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_an_ignored_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncovered_file_lines.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

/// [Analyze] is the main use case of the application.
class Analyze {
  final ParseGitDiff parseGitDiff;
  final Stream<List<String>> filesOnGitDIffStream;
  final IsAGeneratedFile isAGeneratedFile;
  final IsAnIgnoredFile isAnIgnoredFile;
  final SetFileLineResultData setUncoveredLines;
  final GetUncoveredFileLines getUncoveredFileLines;
  final List<String> lcovLines;
  final GetFileReportFromDiff getFileReportFromDiff;
  final UserOptions userOptions;

  const Analyze({
    required this.parseGitDiff,
    required this.filesOnGitDIffStream,
    required this.lcovLines,
    required this.isAGeneratedFile,
    required this.isAnIgnoredFile,
    required this.setUncoveredLines,
    required this.getUncoveredFileLines,
    required this.getFileReportFromDiff,
    required this.userOptions,
  });

  Stream<Report> call() async* {
    int totalOfLinesThatShouldBeTested = 0;
    int totalOfLinesMissingTests = 0;
    int totalUntestedIgnoredLines = 0;

    await for (final fileLines in filesOnGitDIffStream) {
      final FileDiff? fileDiff = parseGitDiff(fileLines);
      if (fileDiff != null && !isAGeneratedFile(fileDiff.path)) {
        final ignoreFile = isAnIgnoredFile(fileDiff.path);
        final uncoveredLinesOnFile = getUncoveredFileLines(lcovLines, fileDiff.path);
        if (uncoveredLinesOnFile != null) {
          setUncoveredLines(fileDiff, uncoveredLinesOnFile);
        } else {
          // Files that are not present in `lcov.info` are ignored.
          // see https://github.com/talesbarreto/pull_request_coverage/issues/23
          continue;
        }
        final fileReport = getFileReportFromDiff(fileDiff, ignoreFile);
        totalOfLinesThatShouldBeTested += fileReport.linesThatShouldBeTestedCount;
        totalOfLinesMissingTests += fileReport.linesMissingTestsCount;
        totalUntestedIgnoredLines += fileReport.untestedAndIgnoredLines;

        yield Report.fileReport(fileReport);
      }
    }

    yield Report.analysisResult(
      AnalysisResult(
        linesThatShouldBeTested: totalOfLinesThatShouldBeTested,
        untestedIgnoredLines: totalUntestedIgnoredLines,
        linesMissingTests: totalOfLinesMissingTests,
      ),
    );
  }
}
