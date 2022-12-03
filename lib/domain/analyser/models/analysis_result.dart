class AnalysisResult {
  final int totalOfNewLines;
  final int totalOfUncoveredNewLines;
  final double coverageRate;

  const AnalysisResult({
    required this.totalOfNewLines,
    required this.totalOfUncoveredNewLines,
  }) : coverageRate = 1 - (totalOfUncoveredNewLines / totalOfNewLines);
}
