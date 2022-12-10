import 'dart:math';

import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';

class PrintResultForFile {
  /// print [printCodeWindow] line of codes before and after the uncovered line
  static const printCodeWindow = 3;
  final bool showUncoveredLines;

  final OutputGenerator outputGenerator;
  final void Function(String message) print;

  const PrintResultForFile({
    required this.print,
    required this.outputGenerator,
    required this.showUncoveredLines,
  });

  void call(FileDiff fileDiff) {
    final outputBuilder = StringBuffer();
    void write(String? message) => message != null ? outputBuilder.write(message) : null;

    write(outputGenerator.getFileHeader(fileDiff.path, fileDiff.uncoveredNewLinesCount, fileDiff.newLinesCount));
    int? lastPrintedLineNumber;

    if (fileDiff.hasUncoveredLines && showUncoveredLines) {
      write(outputGenerator.getSourceCodeHeader());
      for (int i = 0; i < fileDiff.lines.length; i++) {
        final line = fileDiff.lines[i];
        var shouldPrint = line.isAnUncoveredNewLine;
        if (!shouldPrint) {
          // printing [printCodeWindow] codes after and before the uncovered line
          for (int j = max(i - printCodeWindow, 0); j < fileDiff.lines.length && j < printCodeWindow + i + 1; j++) {
            if (fileDiff.lines[j].isAnUncoveredNewLine) {
              shouldPrint = true;
              break;
            }
          }
        }
        if (shouldPrint) {
          if (lastPrintedLineNumber != null && lastPrintedLineNumber + 1 != line.lineNumber) {
            write(outputGenerator.getSourceCodeBlocDivider());
          }
          lastPrintedLineNumber = line.lineNumber;
          write(outputGenerator.getLine(line.line, line.lineNumber, line.isANewLine, line.isUncovered));
        }
      }
      write(outputGenerator.getSourceCodeFooter());
    }
    if (outputBuilder.isNotEmpty) {
      print(outputBuilder.toString());
    }
  }
}
