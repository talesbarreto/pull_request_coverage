import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';

class MarkdownOutputGenerator implements OutputGenerator {
  final bool reportFullyCoveredFiles;
  final bool useColorfulOutput;
  final int fractionalDigits;

  const MarkdownOutputGenerator({
    required this.reportFullyCoveredFiles,
    required this.useColorfulOutput,
    required this.fractionalDigits,
  });

  @override
  String? getSourceCodeHeader() => useColorfulOutput ? "```diff\n" : "```dart\n";

  @override
  String? getSourceCodeFooter() => "```";

  @override
  String? getSourceCodeBlocDivider() {
    return "```\n${getSourceCodeHeader()}";
  }

  @override
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount) {
    if (uncoveredLinesCount == 0) {
      if (reportFullyCoveredFiles) {
        return " - `$filePath` is fully covered (${"+$totalNewLinesCount"})";
      }
      return null;
    }
    return " - `$filePath` has $uncoveredLinesCount uncovered lines (${"+$totalNewLinesCount"})\n";
  }

  @override
  String? getLine(String line, int lineNumber, bool isANewLine, bool isUncovered) {
    if (isANewLine && isUncovered) {
      if (useColorfulOutput) {
        return "${"- $lineNumber: $line"}\n";
      } else {
        return "$line\t// <- MISSING TEST AT LINE $lineNumber\n";
      }
    } else {
      if (useColorfulOutput) {
        return "  $lineNumber: $line\n";
      } else {
        return "$line\n";
      }
    }
  }

  @override
  String? getResume(AnalysisResult analysisResult, double? minimumCoverageRate, int? maximumUncoveredLines) {
    if (analysisResult.totalOfNewLines == 0) {
      return "This pull request has no new lines";
    }

    final boldSurrounding = useColorfulOutput ? "**" : "";

    final outputBuilder = StringBuffer();

    outputBuilder.writeln("------------------------------------");
    outputBuilder.writeln("After ignoring excluded files, this pull request has:");
    outputBuilder.write(" - ${analysisResult.totalOfNewLines} new lines, ");
    if (analysisResult.totalOfUncoveredNewLines == 0) {
      outputBuilder.writeln("ALL of them are covered by tests");
    } else {
      outputBuilder.write("${analysisResult.totalOfUncoveredNewLines} of them are NOT covered by tests. ");
      if (maximumUncoveredLines != null) {
        if (analysisResult.totalOfUncoveredNewLines > maximumUncoveredLines) {
          outputBuilder.write(
            "${boldSurrounding}You can only have up to $maximumUncoveredLines uncovered lines$boldSurrounding",
          );
        } else {
          outputBuilder.write("But....it's enough to pass the test =D");
        }
      }
      outputBuilder.writeln();
    }

    outputBuilder.write(" - ${(analysisResult.coverageRate * 100).toStringAsFixed(fractionalDigits)}% of coverage. ");

    if (minimumCoverageRate != null) {
      if (analysisResult.coverageRate < (minimumCoverageRate / 100)) {
        outputBuilder.write("${boldSurrounding}You need at least $minimumCoverageRate% of coverage$boldSurrounding");
      } else {
        outputBuilder.write("This is above the limit of $minimumCoverageRate%");
      }
    } else {
      outputBuilder.writeln();
    }
    return outputBuilder.toString();
  }
}
