import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class CliOutputGenerator implements OutputGenerator {
  final ColorizeCliText colorizeText;
  final bool reportFullyCoveredFiles;
  final int fractionalDigits;

  const CliOutputGenerator({
    required this.colorizeText,
    required this.reportFullyCoveredFiles,
    required this.fractionalDigits,
  });

  @override
  String? getSourceCodeHeader() => null;

  @override
  String? getSourceCodeFooter() => null;

  @override
  String? getSourceCodeBlocDivider() => "......\n";

  @override
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount) {
    if (uncoveredLinesCount == 0) {
      if (reportFullyCoveredFiles) {
        return "$filePath is fully covered (${colorizeText("+$totalNewLinesCount", TextColor.green)})\n";
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
  String? getResume(AnalysisResult analysisResult, double? minimumCoverageRate, int? maximumUncoveredLines) {
    if (analysisResult.totalOfNewLines == 0) {
      return "This pull request has no new lines";
    }

    final outputBuilder = StringBuffer();

    outputBuilder.writeln("------------------------------------");
    outputBuilder.writeln("After ignoring excluded files, this pull request has:");
    outputBuilder.write("\t- ${analysisResult.totalOfNewLines} new lines, ");
    if (analysisResult.totalOfUncoveredNewLines == 0) {
      outputBuilder.writeln(colorizeText("ALL of them are covered by tests", TextColor.green));
    } else {
      outputBuilder.write(colorizeText("${analysisResult.totalOfUncoveredNewLines} of them are NOT covered by tests. ", TextColor.yellow));
      if (maximumUncoveredLines != null) {
        if (analysisResult.totalOfUncoveredNewLines > maximumUncoveredLines) {
          outputBuilder.write(colorizeText("You can only have up to $maximumUncoveredLines uncovered lines", TextColor.red));
        } else {
          outputBuilder.write(colorizeText("But....it's enough to pass the test =D", TextColor.green));
        }
      }
      outputBuilder.writeln();
    }

    outputBuilder.write("\t- ${(analysisResult.coverageRate * 100).toStringAsFixed(fractionalDigits)}% of coverage. ");

    if (minimumCoverageRate != null) {
      if (analysisResult.coverageRate < (minimumCoverageRate / 100)) {
        outputBuilder.write(colorizeText("You need at least $minimumCoverageRate% of coverage", TextColor.red));
      } else {
        outputBuilder.write(colorizeText("This is above the limit of $minimumCoverageRate%", TextColor.green));
      }
    } else {
      outputBuilder.writeln();
    }
    return outputBuilder.toString();
  }
}
