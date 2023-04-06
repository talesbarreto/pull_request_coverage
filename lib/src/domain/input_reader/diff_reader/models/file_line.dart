/// [isUntested] is `false` when `FileLine` is created by `ParseGitDiff`
/// To coverage will be analysed by `Analyze` use case and this value will be updated there.
///
/// [isANewLine] tells if this line was added in the current PR.
class FileLine {
  final String line;
  final int lineNumber;
  final bool isANewLine;
  bool? isUntested;
  bool? ignored;

  FileLine({
    required this.line,
    required this.lineNumber,
    required this.isANewLine,
    this.isUntested,
    this.ignored,
  });

  bool get isANewNotIgnoredLine => isANewLine && ignored == false;

  bool get isTestMissing => isANewLine && isUntested == true && ignored == false;

  @override
  String toString() => "$lineNumber ${isTestMissing ? "💃" : "👍"}: $line";
}
