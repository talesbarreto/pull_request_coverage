class UserOptions {
  final List<String> excludePrefixPaths;
  final List<String> excludeSuffixPaths;
  final String lcovFilePath;
  final double? minimumCoverageRate;
  final int? maximumUncoveredLines;
  final bool showUncoveredLines;


  const UserOptions({
    required this.excludePrefixPaths,
    required this.excludeSuffixPaths,
    required this.lcovFilePath,
    required this.showUncoveredLines,
    this.minimumCoverageRate,
    this.maximumUncoveredLines,
  });
}
