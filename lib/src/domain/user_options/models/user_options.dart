class UserOptions {
  final List<String> excludePrefixPaths;
  final List<String> excludeSuffixPaths;
  final String lcovFilePath;
  final double? minimumCoverageRate;
  final int? maximumUncoveredLines;
  final bool showUncoveredCode;
  final bool useColorfulFont;
  final bool reportFullyCoveredFiles;

  const UserOptions({
    required this.excludePrefixPaths,
    required this.excludeSuffixPaths,
    required this.lcovFilePath,
    required this.showUncoveredCode,
    this.minimumCoverageRate,
    this.maximumUncoveredLines,
    this.useColorfulFont = true,
    this.reportFullyCoveredFiles = true,
  });
}
