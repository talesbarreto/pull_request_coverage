import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';

abstract class OutputGenerator {
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount);

  String? getSourceCodeHeader();

  String? getLine(String line, int lineNumber, bool isANewLine, bool isCovered);

  /// [getSourceCodeBlocDivider] is used to separate the source code blocs in the same file
  String? getSourceCodeBlocDivider();

  String? getSourceCodeFooter();

  String? getReport(AnalysisResult analysisResult, double? minimumCoverageRate, int? maximumUncoveredLines);
}
