import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';
import 'package:pull_request_coverage/src/presentation/logger/logger.dart';

/// [GetUncoveredFileLines] returns a list of line index that are not covered by tests.
class GetUncoveredFileLines {
  bool _isSamePath(String filePath, String lcovFileHeader) {
    if (lcovFileHeader.startsWith("SF:$filePath")) {
      return true;
    }

    final indexOfLib = lcovFileHeader.indexOf("/lib/");
    if (indexOfLib > 0 &&
            !filePath.startsWith("/") // file path received on git diff is not absolute
            &&
            lcovFileHeader.startsWith("SF:/") //file path on lcov.info file is absolute
            &&
            lcovFileHeader.substring(indexOfLib + 1) == filePath //
        ) {
      return true;
    }
    return false;
  }

  List<int>? call(List<String> lcovInfoLines, String filePath) {
    // most of this code was created by copilot. I'm scared 😰
    for (var i = 0; i < lcovInfoLines.length; i++) {
      final line = lcovInfoLines[i];
      if (_isSamePath(filePath, line)) {
        final uncoveredLines = <int>[];
        for (var j = i + 1; j < lcovInfoLines.length; j++) {
          final line = lcovInfoLines[j];
          if (line.startsWith("end_of_record")) {
            return uncoveredLines;
          }
          if (line.startsWith("DA:")) {
            final lineInfo = line.substring(line.indexOf(":") + 1).split(",");
            final lineNumber = int.parse(lineInfo[0]);
            final covered = lineInfo[1] != "0";
            if (!covered) {
              uncoveredLines.add(lineNumber);
            }
          }
        }
      }
    }
    logger.log(
      tag: "GetUncoveredFileLines",
      message: "coverage info of `$filePath` not found in lcov.info",
      level: LogLevel.verbose,
    );
    return null;
  }
}
