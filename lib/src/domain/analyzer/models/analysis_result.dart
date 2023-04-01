class AnalysisResult {
  final int totalOfNewLines;
  final int totalOfUncoveredNewLines;
  final int totalOfIgnoredLinesMissingTests;
  final double coverageRate;

  const AnalysisResult({
    required this.totalOfNewLines,
    required this.totalOfUncoveredNewLines,
    required this.totalOfIgnoredLinesMissingTests,
  }) : coverageRate = 1 - (totalOfUncoveredNewLines / totalOfNewLines);
}
