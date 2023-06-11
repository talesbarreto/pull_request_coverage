import 'dart:io';

import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';
import 'package:pull_request_coverage/src/extensions/string.dart';

/// Parses a segment of the git diff, that represents one single file on this diff, and returns a [FileDiff] object.
class ParseGitDiff {
  final String Function(String path) transformDiffPath;

  const ParseGitDiff(this.transformDiffPath);

  int _parseFirstLineNumber(String header) {
    // example: "@@ -13,7 +13,7 @@ workspace:"
    final numberString = header.split(" ")[2].substring(1).split(",")[0];
    return int.parse(numberString);
  }

  FileDiff? call(List<String> fileLines) {
    final diffPath = fileLines[0].split(" ").last;
    var index = fileLines.indexWhere((line) => line.startsWith("@@"));
    if (index < 0) return null;

    final lines = <FileLine>[];
    int lineNumber = _parseFirstLineNumber(fileLines[index]);

    for (; index < fileLines.length; index++) {
      final line = fileLines[index];
      if (line.startsWith("@@")) {
        lineNumber = _parseFirstLineNumber(fileLines[index]) - 1;
        continue;
      }
      if (!line.startsWith("-")) {
        lineNumber++;
        lines.add(
          FileLine(
            code: line.removePrefix("+"),
            lineNumber: lineNumber,
            isNew: line.startsWith("+"),
          ),
        );
      }
    }

    final fileRelativePath = diffPath.substring(diffPath.indexOf(Platform.pathSeparator) + 1);
    return FileDiff(
      lines: lines,
      path: transformDiffPath(fileRelativePath),
    );
  }
}
