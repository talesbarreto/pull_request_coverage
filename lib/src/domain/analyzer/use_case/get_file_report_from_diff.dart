import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'dart:math' as math;

import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';

class GetFileReportFromDiff {
  static const printCodeFrame = 3;

  const GetFileReportFromDiff();

  FileReport call(
    FileDiff fileDiff,
    bool isAIgnoredFile,
  ) {
    final List<List<FileLine>> chunks = [];
    int? lastPrintedLineNumber;

    if (fileDiff.hasUncoveredLines) {
      var currentChunk = <FileLine>[];
      for (int i = 0; i < fileDiff.lines.length; i++) {
        final line = fileDiff.lines[i];
        var shouldLog = line.isTestMissing;
        if (!shouldLog) {
          for (int j = math.max(i - printCodeFrame, 0); j < fileDiff.lines.length && j < printCodeFrame + i + 1; j++) {
            if (fileDiff.lines[j].isTestMissing) {
              shouldLog = true;
              break;
            }
          }
        }
        if (shouldLog) {
          if (lastPrintedLineNumber != null &&
              lastPrintedLineNumber + 1 != line.lineNumber &&
              currentChunk.isNotEmpty) {
            chunks.add(currentChunk);
            currentChunk = <FileLine>[];
          }
          lastPrintedLineNumber = line.lineNumber;
          currentChunk.add(line);
        }
      }
      if (currentChunk.isNotEmpty) {
        chunks.add(currentChunk);
      }
    }
    return FileReport(
      filePath: fileDiff.path,
      chunks: chunks,
      newLinesCount: fileDiff.lines.where((line) => line.isNew).length,
      linesThatShouldBeTestedCount:
          isAIgnoredFile ? 0 : fileDiff.lines.where((line) => line.isANewNotIgnoredLine).length,
      linesMissingTestsCount: isAIgnoredFile ? 0 : fileDiff.lines.where((element) => element.isTestMissing).length,
      untestedAndIgnoredLines: fileDiff.lines.where((line) {
        return line.isNew == true && line.isUntested == true && (line.ignored == true || isAIgnoredFile);
      }).length,
    );
  }
}
