import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/plain_text_output_generator.dart';

class MarkdownOutputGenerator with PlainTextOutputGenerator {
  final UserOptions userOptions;
  final GetResultTable getResultTable;
  const MarkdownOutputGenerator({
    required this.userOptions,
    required this.getResultTable,
    required this.print,
  });

  @override
  final void Function(String message) print;

  @override
  bool get showUncoveredCode => userOptions.showUncoveredCode;

  @override
  String? getSourceCodeHeader() => userOptions.markdownMode == MarkdownMode.diff ? "```diff\n" : "```dart\n";

  @override
  String? getSourceCodeFooter() => "```";

  @override
  String? getSourceCodeBlocDivider() {
    return "```\n${getSourceCodeHeader()}";
  }

  @override
  String? getFileHeader(String filePath, int uncoveredLinesCount, int totalNewLinesCount) {
    if (uncoveredLinesCount == 0) {
      if (userOptions.reportFullyCoveredFiles) {
        return " - `$filePath` is fully covered (${"+$totalNewLinesCount"})";
      }
      return null;
    }
    return " - `$filePath` has $uncoveredLinesCount uncovered lines (${"+$totalNewLinesCount"})\n";
  }

  @override
  String? getLine(String line, int lineNumber, bool isANewLine, bool isUncovered) {
    if (isANewLine && isUncovered) {
      if (userOptions.markdownMode == MarkdownMode.diff) {
        return "${"- $lineNumber: $line"}\n";
      } else {
        return "$line\t// <- MISSING TEST AT LINE $lineNumber\n";
      }
    } else {
      if (userOptions.markdownMode == MarkdownMode.diff) {
        return "  $lineNumber: $line\n";
      } else {
        return "$line\n";
      }
    }
  }

  @override
  String getReport(AnalysisResult analysisResult) {
    if (analysisResult.totalOfUncoveredNewLines == 0 && userOptions.fullyTestedMessage != null) {
      return userOptions.fullyTestedMessage!;
    }
    return "\n${getResultTable(analysisResult)}";
  }
}
