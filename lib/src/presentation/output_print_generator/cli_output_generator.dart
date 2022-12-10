import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';

class CliOutputGenerator implements OutputGenerator {
  final ColorizeText colorizeText;
  final bool reportFullyCoveredFiles;
  final bool showUncoveredLines;

  const CliOutputGenerator({
    required this.colorizeText,
    required this.reportFullyCoveredFiles,
    required this.showUncoveredLines,
  });

  @override
  String? getSourceCodeHeader() => null;

  @override
  String? getSourceCodeFooter() => null;

  @override
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount) {
    if (uncoveredLinesCount == 0) {
      return "$filePath is fully covered (${colorizeText("+$totalNewLinesCount", TextColor.green)})\n";
    }
    return "${colorizeText(filePath, TextColor.red)} has $uncoveredLinesCount uncovered lines (${colorizeText("+$totalNewLinesCount", TextColor.green)})\n";
  }

  @override
  String? getLine(String line, int lineNumber, bool isANewLine, bool isUncovered) {
    if (isANewLine && isUncovered) {
      return "${colorizeText("[$lineNumber]: ${line.replaceFirst("+", "→")}", TextColor.red)}\n";
    } else {
      return " $lineNumber : $line\n";
    }
  }
}
