import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/plain_text_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class MarkdownOutputGenerator with PlainTextOutputGenerator {
  @override
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
  String formatFileHeader(String text) => " - `$text";

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

  @override
  ColorizeCliText? get colorizeCliText => null;
}
