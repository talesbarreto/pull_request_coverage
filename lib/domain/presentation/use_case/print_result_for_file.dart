import 'dart:math';

import 'package:pull_request_coverage/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/domain/presentation/use_case/text_color.dart';

class PrintResultForFile {
  /// print [printCodeWindow] line of codes before and after the uncovered line
  static const printCodeWindow = 3;

  final void Function(String message) print;

  const PrintResultForFile(this.print);

  void call(FileDiff fileDiff) {
    final outputBuilder = StringBuffer();
    if (fileDiff.hasUncoveredLines) {
      outputBuilder.writeln(
          "${TextColor.colorize(fileDiff.path, TextColor.red)} has uncovered lines 👀  (${TextColor.colorize("+${fileDiff.newLinesCount}", TextColor.green)})");
      for (int i = 0; i < fileDiff.lines.length; i++) {
        final line = fileDiff.lines[i];
        var shouldPrint = line.isAnUncoveredNewLine;
        if (!shouldPrint) {
          // printing [printCodeWindow] codes after and before the uncovered line
          for (int j = max(i - printCodeWindow, 0);
              j < fileDiff.lines.length && j < printCodeWindow + i + 1;
              j++) {
            if (fileDiff.lines[j].isAnUncoveredNewLine) {
              shouldPrint = true;
              break;
            }
          }
        }
        if (shouldPrint) {
          if (line.isAnUncoveredNewLine) {
            outputBuilder.writeln(
                TextColor.colorize(" ⬤  : ${line.line}", TextColor.red));
          } else {
            outputBuilder.writeln(" ${line.lineNumber} : ${line.line}");
          }
        }
      }
    } else {
      outputBuilder.write(
          "${fileDiff.path} is fully covered 🎉 (${TextColor.colorize("+${fileDiff.newLinesCount}", TextColor.green)})");
    }
    print(outputBuilder.toString());
  }
}
