abstract class OutputGenerator {
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount);

  String? getSourceCodeHeader();

  String? getLine(String line, int lineNumber, bool isANewLine, bool isCovered);

  String? getSourceCodeFooter();
}
