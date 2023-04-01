import 'package:pull_request_coverage/src/domain/analyser/use_case/should_analyze_this_file.dart';
import 'package:pull_request_coverage/src/domain/analyser/use_case/should_analyze_this_line.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';

class SetUncoveredLinesOnFileDiff {
  final ShouldAnalyzeThisLine shouldAnalyzeThisLine;

  const SetUncoveredLinesOnFileDiff(this.shouldAnalyzeThisLine);

  void call(FileDiff fileDiff, List<int> uncoveredLines) {
    for (final line in fileDiff.lines) {
      if (uncoveredLines.contains(line.lineNumber) && shouldAnalyzeThisLine(line.line)) {
        line.isUncovered = true;
      }
    }
  }
}
