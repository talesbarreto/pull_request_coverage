/// [GetUncoveredFileLines] returns a list of line index that are not covered by tests.
class GetUncoveredFileLines {
  List<int>? call(List<String> lcovInfoLines, String filePath) {
    // most of this code was created by copilot. I'm scared 😰
    for (var i = 0; i < lcovInfoLines.length; i++) {
      final line = lcovInfoLines[i];
      if (line.startsWith("SF:$filePath")) {
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
    return null;
  }
}
