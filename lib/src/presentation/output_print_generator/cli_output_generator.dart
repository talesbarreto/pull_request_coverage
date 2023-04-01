import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/cli_table_builder.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class CliOutputGenerator implements OutputGenerator {
  final ColorizeCliText colorizeText;
  final UserOptions userOptions;

  const CliOutputGenerator({
    required this.colorizeText,
    required this.userOptions,
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
  String? getReport(AnalysisResult analysisResult, double? minimumCoverageRate, int? maximumUncoveredLines) {
    if (analysisResult.totalOfNewLines == 0) {
      return "This pull request has no new lines under `/lib`";
    }

    if (analysisResult.totalOfUncoveredNewLines == 0 && userOptions.fullyTestedMessage != null) {
      return userOptions.fullyTestedMessage;
    }

    final currentCoverage = (analysisResult.coverageRate * 100).toStringAsFixed(userOptions.fractionalDigits);

    String result(bool success) => success ? colorizeText("Success", TextColor.green) : colorizeText("FAIL", TextColor.red);

    final linesResult = maximumUncoveredLines == null ? "-" : result(analysisResult.totalOfUncoveredNewLines <= maximumUncoveredLines);
    final lineThreshold = maximumUncoveredLines == null ? "-" : "$maximumUncoveredLines";
    final rateResult = minimumCoverageRate == null ? "-" : result(analysisResult.coverageRate >= (minimumCoverageRate / 100));
    final rateThreshold = minimumCoverageRate == null ? "-" : "$minimumCoverageRate%";

    final tableBuilder = CliTableBuilder(columnsLength: 4, header: ["Report", "Current value", "Threshold", "Result"]);

    tableBuilder.addLine(["Lines that should be tested", analysisResult.totalOfNewLines.toString(), "", ""]);
    tableBuilder.addLine(["Uncovered new lines", analysisResult.totalOfUncoveredNewLines.toString(), lineThreshold, linesResult]);
    tableBuilder.addLine(["Coverage rate", "$currentCoverage%", rateThreshold, rateResult]);

    return "\n${tableBuilder.build()}";
  }
}
