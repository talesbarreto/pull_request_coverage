import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';

/// [lines] contains all lines but removed ones provided by the git diff
class FileDiff {
  final String path;
  final List<FileLine> lines;

  bool get hasUncoveredLines => lines.any((line) => line.isAnUncoveredNewLine);

  int get newLinesCount => lines.where((line) => line.isANewLine).length;

  const FileDiff({
    required this.path,
    required this.lines,
  });
}
