import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';

class MarkdownOutputGenerator implements OutputGenerator {
  final bool reportFullyCoveredFiles;
  final MarkdownMode markdownMode;
  final int fractionalDigits;

  const MarkdownOutputGenerator({
    required this.reportFullyCoveredFiles,
    required this.markdownMode,
    required this.fractionalDigits,
  });

  @override
  String? getSourceCodeHeader() => markdownMode == MarkdownMode.diff ? "```diff\n" : "```dart\n";

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
      if (markdownMode == MarkdownMode.diff) {
        return "${"- $lineNumber: $line"}\n";
      } else {
        return "$line\t// <- MISSING TEST AT LINE $lineNumber\n";
      }
    } else {
      if (markdownMode == MarkdownMode.diff) {
        return "  $lineNumber: $line\n";
      } else {
        return "$line\n";
      }
    }
  }

  @override
  String? getReport(AnalysisResult analysisResult, double? minimumCoverageRate, int? maximumUncoveredLines) {
    if (analysisResult.totalOfNewLines == 0) {
      return "This pull request has no new lines under `/lib`";
    }

    final outputBuilder = StringBuffer();
    final currentCoverage = (analysisResult.coverageRate * 100).toStringAsFixed(fractionalDigits);

    String result(bool success) => success ? "Success" : "**FAIL**";

    final linesResult = maximumUncoveredLines == null ? "-" : result(analysisResult.totalOfUncoveredNewLines <= maximumUncoveredLines);
    final lineThreshold = maximumUncoveredLines == null ? "-" : "$maximumUncoveredLines";
    final rateResult = minimumCoverageRate == null ? "-" : result(analysisResult.coverageRate >= (minimumCoverageRate / 100));
    final rateThreshold = minimumCoverageRate == null ? "-" : "$minimumCoverageRate%";

    outputBuilder.writeln("### Report");
    outputBuilder.writeln("|                         | Current value                                   | Threshold      | Result        |");
    outputBuilder.writeln("|-------------------------|-------------------------------------------------|----------------|---------------|");
    outputBuilder.writeln("| New lines under  `/lib` | ${analysisResult.totalOfNewLines}               |                |               |");
    outputBuilder.writeln("| Uncovered new lines     | ${analysisResult.totalOfUncoveredNewLines}      | $lineThreshold | $linesResult  |");
    outputBuilder.writeln("| Coverage rate           | $currentCoverage%                               | $rateThreshold | $rateResult   |");

    return outputBuilder.toString();
  }
}
