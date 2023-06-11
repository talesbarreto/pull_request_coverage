import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';

class FileReport {
  final String filePath;
  final List<List<FileLine>> chunks;
  final int newLinesCount;
  final int linesThatShouldBeTestedCount;
  final int linesMissingTestsCount;
  final int untestedAndIgnoredLines;

  const FileReport({
    required this.filePath,
    required this.chunks,
    required this.newLinesCount,
    required this.linesThatShouldBeTestedCount,
    required this.linesMissingTestsCount,
    required this.untestedAndIgnoredLines,
  });
}
