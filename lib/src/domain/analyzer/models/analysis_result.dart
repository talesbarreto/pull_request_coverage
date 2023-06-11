class AnalysisResult {
  final int linesThatShouldBeTested;
  final int linesMissingTests;
  final int untestedIgnoredLines;
  final int? linesMissingTestsThreshold;
  final double? coverageRateThreshold;
  final double coverageRate;

  const AnalysisResult({
    required this.linesThatShouldBeTested,
    required this.linesMissingTests,
    required this.untestedIgnoredLines,
    required this.linesMissingTestsThreshold,
    required this.coverageRateThreshold,
  }) : coverageRate = 1 - (linesMissingTests / linesThatShouldBeTested);
}
