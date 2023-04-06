import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';

/// [lines] contains all lines but removed ones provided by the git diff
class FileDiff {
  final String path;
  final List<FileLine> lines;

  bool get hasUncoveredLines => lines.any((line) => line.isTestMissing);

  int get newLinesCount => lines.where((line) => line.isANewLine).length;
  int get uncoveredNewLinesCount => lines.where((line) => line.isTestMissing).length;
  int get ignoredUntestedLinesCount => lines.where((line) => line.ignored == true && line.isUntested == true && line.isANewLine).length;

  const FileDiff({
    required this.path,
    required this.lines,
  });
}
