class FileLine {
  final String line;
  final int lineNumber;
  final bool isANewLine;
  bool isUncovered;

  FileLine({
    required this.line,
    required this.lineNumber,
    required this.isANewLine,
    this.isUncovered = false,
  });

  bool get isAnUncoveredNewLine => isANewLine && isUncovered;

  @override
  String toString() => "$lineNumber ${isAnUncoveredNewLine ? "💃" : "👍"}: $line";
}
