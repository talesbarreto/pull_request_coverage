import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/plain_text_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class MarkdownOutputGenerator extends PlainTextOutputGenerator {
  const MarkdownOutputGenerator(
      {required super.colorizeCliText, required super.print, required super.tableBuilder, required super.userOptions});

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
  ColorizeCliText? get colorizeCliText => null;

  @override
  String getFileHeader(String filePath, int newLinesCount, int ignoredUntestedLines, int missingTestsLines) {
    final ignoredText = ignoredUntestedLines > 0 ? "$ignoredUntestedLines untested and ignored" : null;
    final untestedText = missingTestsLines > 0 ? "$missingTestsLines lines missing tests" : null;

    return " - `$filePath` (+$newLinesCount)"
        "${ignoredText != null ? " / _${ignoredText}_ " : ""}"
        "${untestedText != null ? " / **$untestedText** " : ""}"
        "${ignoredText != null || untestedText != null ? "\n" : ""}";
  }
}
