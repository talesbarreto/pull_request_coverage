import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';

abstract class OutputGenerator {
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount);

  String? getSourceCodeHeader();

  String? getLine(String line, int lineNumber, bool isANewLine, bool isCovered);

  String? getSourceCodeFooter();

  String? getResume(AnalysisResult analysisResult, double? minimumCoverageRate, int? maximumUncoveredLines);
}
