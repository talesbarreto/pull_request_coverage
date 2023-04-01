import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class CliOutputGenerator implements OutputGenerator {
  final ColorizeCliText colorizeText;
  final UserOptions userOptions;
  final GetResultTable getResultTable;

  const CliOutputGenerator({
    required this.colorizeText,
    required this.userOptions,
    required this.getResultTable,
  });

  @override
  String? getSourceCodeHeader() => null;

  @override
  String? getSourceCodeFooter() => null;

  @override
  String? getSourceCodeBlocDivider() => "......\n\n";

  @override
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount) {
    if (uncoveredLinesCount == 0) {
      if (userOptions.reportFullyCoveredFiles) {
        return "$filePath is fully covered (${colorizeText("+$totalNewLinesCount", TextColor.green)})";
      }
      return null;
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

  @override
  String? getReport(AnalysisResult analysisResult) {
    if (analysisResult.totalOfUncoveredNewLines == 0 && userOptions.fullyTestedMessage != null) {
      return userOptions.fullyTestedMessage;
    }

    return "\n${getResultTable(analysisResult)}";
  }
}
