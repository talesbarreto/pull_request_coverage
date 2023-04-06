class AnalysisResult {
  final int linesShouldBeTested;
  final int linesMissingTests;
  final int ignoredLinesMissingTests;
  final double coverageRate;

  const AnalysisResult({
    required this.linesShouldBeTested,
    required this.linesMissingTests,
    required this.ignoredLinesMissingTests,
  }) : coverageRate = 1 - (linesMissingTests / linesShouldBeTested);
}
