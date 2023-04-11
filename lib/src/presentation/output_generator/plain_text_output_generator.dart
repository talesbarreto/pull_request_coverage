import 'dart:math';
import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/table_builder.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

abstract class PlainTextOutputGenerator implements OutputGenerator {
  static const printCodeFrame = 3;

  const PlainTextOutputGenerator({
    required this.tableBuilder,
    required this.userOptions,
    required this.colorizeCliText,
    required this.print,
  });

  final void Function(String message) print;

  final UserOptions userOptions;

  final ColorizeCliText? colorizeCliText;

  final TableBuilder tableBuilder;

  String getFileHeader(String filePath, int newLinesCount, int ignoredUntestedLines, int missingTestsLines);

  String formatFileHeader(String text);

  String? getSourceCodeHeader();

  String? getLine(String line, int lineNumber, bool isANewLine, bool isUntested);

  /// [getSourceCodeBlocDivider] is used to separate the source code blocs in the same file
  String? getSourceCodeBlocDivider();

  String? getSourceCodeFooter();

  // since [PlainTextOutputGenerator] prints everything on the fly, [printOutput] does nothing
  @override
  void printOutput() {}

  String colorizeText(String text, TextColor color) =>
      colorizeCliText != null ? colorizeCliText!.call(text, color) : text;

  @override
  void addFile(FileDiff fileDiff) {
    final outputBuilder = StringBuffer();
    void write(String? message) => message != null ? outputBuilder.write(message) : null;
    if (!userOptions.reportFullyCoveredFiles && !fileDiff.hasUncoveredLines) {
      return;
    }
    write(getFileHeader(
      fileDiff.path,
      fileDiff.newLinesCount,
      fileDiff.ignoredUntestedLinesCount,
      fileDiff.uncoveredNewLinesCount,
    ));
    int? lastPrintedLineNumber;

    if (fileDiff.hasUncoveredLines && userOptions.showUncoveredCode) {
      write(getSourceCodeHeader());
      for (int i = 0; i < fileDiff.lines.length; i++) {
        final line = fileDiff.lines[i];
        var shouldPrint = line.isTestMissing;
        if (!shouldPrint) {
          // printing [printCodeFrame] codes after and before the uncovered line
          for (int j = max(i - printCodeFrame, 0); j < fileDiff.lines.length && j < printCodeFrame + i + 1; j++) {
            if (fileDiff.lines[j].isTestMissing) {
              shouldPrint = true;
              break;
            }
          }
        }
        if (shouldPrint) {
          if (lastPrintedLineNumber != null && lastPrintedLineNumber + 1 != line.lineNumber) {
            write(getSourceCodeBlocDivider());
          }
          lastPrintedLineNumber = line.lineNumber;
          write(getLine(line.line, line.lineNumber, line.isANewLine, line.isTestMissing));
        }
      }
      write(getSourceCodeFooter());
    }
    if (outputBuilder.isNotEmpty) {
      print(outputBuilder.toString());
    }
  }

  @override
  void setReport(AnalysisResult analysisResult) {
    final maximumUncoveredLines = userOptions.maximumUncoveredLines;
    final minimumCoverageRate = userOptions.minimumCoverageRate;

    final coverage = (analysisResult.coverageRate * 100);
    final coverageTxt = coverage.isNaN ? "-" : "${coverage.toStringAsFixed(userOptions.fractionalDigits)}%";

    String result(bool success) =>
        success ? colorizeText("Success", TextColor.green) : colorizeText("FAIL", TextColor.red);

    final linesResult =
        maximumUncoveredLines == null ? "-" : result(analysisResult.linesMissingTests <= maximumUncoveredLines);
    final lineThreshold = maximumUncoveredLines == null ? "-" : "$maximumUncoveredLines";
    final rateResult = minimumCoverageRate == null || analysisResult.coverageRate.isNaN
        ? "-"
        : result(analysisResult.coverageRate >= (minimumCoverageRate / 100));
    final rateThreshold = minimumCoverageRate == null ? "-" : "$minimumCoverageRate%";

    final ignoredUntestedLinesText = colorizeText(
      analysisResult.untestedIgnoredLines.toString(),
      ColorizeCliText.ignoredUntestedCodeColor,
    );

    tableBuilder
      ..setHeader(["Report", "Current value", "Threshold", ""])
      ..addLine(["Lines that should be tested", analysisResult.linesShouldBeTested.toString(), "", ""])
      ..addLine(["Ignored untested lines", ignoredUntestedLinesText, "", ""])
      ..addLine(["Lines missing tests", analysisResult.linesMissingTests.toString(), lineThreshold, linesResult])
      ..addLine(["Coverage rate", coverageTxt, rateThreshold, rateResult]);

    print("\n${tableBuilder.build(userOptions.outputMode == OutputMode.markdown)}");
  }
}
