import 'dart:math';

import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';

class PrintResultForFile {
  /// print [printCodeWindow] line of codes before and after the uncovered line
  static const printCodeWindow = 3;

  final void Function(String message) print;
  final ColorizeText colorizeText;
  final bool reportFullyCoveredFiles;
  final bool showUncoveredLines;

  const PrintResultForFile({
    required this.print,
    required this.colorizeText,
    required this.reportFullyCoveredFiles,
    required this.showUncoveredLines,
  });

  void call(FileDiff fileDiff) {
    final outputBuilder = StringBuffer();
    if (fileDiff.hasUncoveredLines) {
      outputBuilder.writeln("${colorizeText(fileDiff.path, TextColor.red)} has ${fileDiff.uncoveredNewLinesCount} uncovered lines (${colorizeText("+${fileDiff.newLinesCount}", TextColor.green)})");
      if (showUncoveredLines) {
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
            if (line.isAnUncoveredNewLine) {
              outputBuilder.writeln(colorizeText("[${line.lineNumber}]: ${line.line.replaceFirst("+", "→")}", TextColor.red));
            } else {
              outputBuilder.writeln(" ${line.lineNumber} : ${line.line}");
            }
          }
        }
      }
    } else {
      if (reportFullyCoveredFiles) {
        outputBuilder.write("${fileDiff.path} is fully covered (${colorizeText("+${fileDiff.newLinesCount}", TextColor.green)})");
      }
    }
    if (outputBuilder.isNotEmpty) {
      print(outputBuilder.toString());
    }
  }
}
