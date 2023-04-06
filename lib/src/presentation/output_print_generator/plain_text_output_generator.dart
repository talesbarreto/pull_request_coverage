import 'dart:math';
import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';

mixin PlainTextOutputGenerator implements OutputGenerator {
  static const printCodeWindow = 3;
  void Function(String message) get print;
  bool get showUncoveredCode;

  String? getFileHeader(FileDiff fileDiff);

  String? getSourceCodeHeader();

  String? getLine(String line, int lineNumber, bool isANewLine, bool isUntested);

  /// [getSourceCodeBlocDivider] is used to separate the source code blocs in the same file
  String? getSourceCodeBlocDivider();

  String? getSourceCodeFooter();

  String getReport(AnalysisResult analysisResult);

  // since [PlainTextOutputGenerator] prints everything on the fly, [printOutput] does nothing
  @override
  void printOutput() {}

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

  @override
  void printFatalError(String msg, error, StackTrace? stackTrace) {
    print("${error?.toString() ?? msg} ${stackTrace != null ? "\ntackTrace.toString()" : ""}");
  }
}
