import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';

class SetUncoveredLinesOnFileDiff {
  void call(FileDiff fileDiff, List<int> uncoveredLines) {
    for (final line in fileDiff.lines) {
      if (uncoveredLines.contains(line.lineNumber)) {
        line.isUncovered = true;
      }
    }
  }
}
