import 'package:pull_request_coverage/src/domain/analyzer/use_case/should_analyze_this_line.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';

class SetFileLineResultData {
  final ShouldAnalyzeThisLine shouldAnalyzeThisLine;

  const SetFileLineResultData(this.shouldAnalyzeThisLine);

  void call(FileDiff fileDiff, List<int> uncoveredLines) {
    for (final line in fileDiff.lines) {
      line.isUncovered = uncoveredLines.contains(line.lineNumber);
      line.ignored = !shouldAnalyzeThisLine(line.line);
    }
  }
}
