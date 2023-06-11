/// [isUntested] is `false` when `FileLine` is created by `ParseGitDiff`
/// To coverage will be analysed by `Analyze` use case and this value will be updated there.
///
/// [isNew] tells if this line was added in the current PR.
class FileLine {
  final String code;
  final int lineNumber;
  final bool isNew;
  bool? isUntested;
  bool? ignored;

  FileLine({
    required this.code,
    required this.lineNumber,
    required this.isNew,
    this.isUntested,
    this.ignored,
  });

  bool get isANewNotIgnoredLine => isNew && ignored == false;

  bool get isTestMissing => isNew && isUntested == true && ignored == false;
}
