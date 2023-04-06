import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
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
  String? getFileHeader(FileDiff fileDiff) {
    final filePath = fileDiff.path;
    final uncoveredLinesCount = fileDiff.uncoveredNewLinesCount;
    final totalNewLinesCount = fileDiff.newLinesCount;
    final ignoredMsg = fileDiff.ignoredUntestedLinesCount > 0
        ? " / ${"${fileDiff.ignoredUntestedLinesCount} untested and ignored"}"
        : "";
    if (uncoveredLinesCount == 0) {
      if (userOptions.reportFullyCoveredFiles) {
        return " - `$filePath` is fully covered (${"+$totalNewLinesCount"}$ignoredMsg)";
      }
      return null;
    }
    return " - `$filePath` has $uncoveredLinesCount uncovered lines (${"+$totalNewLinesCount"}$ignoredMsg)\n";
  }

  @override
  String? getLine(String line, int lineNumber, bool isANewLine, bool isUntested) {
    if (isANewLine && isUntested) {
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
    if (analysisResult.linesMissingTests == 0 && userOptions.fullyTestedMessage != null) {
      return userOptions.fullyTestedMessage!;
    }
    return "\n${getResultTable(analysisResult)}";
  }
}
