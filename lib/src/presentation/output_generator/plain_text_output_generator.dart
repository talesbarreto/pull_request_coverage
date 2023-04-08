import 'dart:math';
import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

mixin PlainTextOutputGenerator implements OutputGenerator {
  static const printCodeWindow = 3;
  void Function(String message) get print;
  UserOptions get userOptions;
  bool get showUncoveredCode;
  ColorizeCliText? get colorizeCliText;

  String formatFileHeader(String text);

  String? getSourceCodeHeader();

  String? getLine(String line, int lineNumber, bool isANewLine, bool isUntested);

  /// [getSourceCodeBlocDivider] is used to separate the source code blocs in the same file
  String? getSourceCodeBlocDivider();

  String? getSourceCodeFooter();

  String getReport(AnalysisResult analysisResult);

  // since [PlainTextOutputGenerator] prints everything on the fly, [printOutput] does nothing
  @override
  void printOutput() {}

  String colorizeText(String text, TextColor color) =>
      colorizeCliText != null ? colorizeCliText!.call(text, color) : text;

  String? getFileHeader(FileDiff fileDiff) {
    final filePath = fileDiff.path;
    final uncoveredLinesCount = fileDiff.uncoveredNewLinesCount;
    final totalNewLinesCount = fileDiff.newLinesCount;
    final ignoredMsg = fileDiff.ignoredUntestedLinesCount > 0
        ? " / ${colorizeText("${fileDiff.ignoredUntestedLinesCount} untested and ignored", ColorizeCliText.ignoredUntestedCodeColor)}"
        : "";
    if (uncoveredLinesCount == 0) {
      if (userOptions.reportFullyCoveredFiles) {
        return "$filePath is fully covered (${colorizeText("+$totalNewLinesCount", TextColor.green)}$ignoredMsg)";
      }
      return null;
    }
    return "${colorizeText(filePath, TextColor.yellow)}"
    ": ${colorizeText("$uncoveredLinesCount lines missing tests",TextColor.red)}"
    " (${colorizeText("+$totalNewLinesCount", TextColor.green)} "
    "$ignoredMsg)\n";
  }

  @override
  void addFile(FileDiff fileDiff) {
    final outputBuilder = StringBuffer();
    void write(String? message) => message != null ? outputBuilder.write(message) : null;

    write(getFileHeader(fileDiff));
    int? lastPrintedLineNumber;

    if (fileDiff.hasUncoveredLines && showUncoveredCode) {
      write(getSourceCodeHeader());
      for (int i = 0; i < fileDiff.lines.length; i++) {
        final line = fileDiff.lines[i];
        var shouldPrint = line.isTestMissing;
        if (!shouldPrint) {
          // printing [printCodeWindow] codes after and before the uncovered line
          for (int j = max(i - printCodeWindow, 0); j < fileDiff.lines.length && j < printCodeWindow + i + 1; j++) {
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
    print(getReport(analysisResult));
  }
}
