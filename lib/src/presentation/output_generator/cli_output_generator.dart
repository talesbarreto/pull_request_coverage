import 'package:pull_request_coverage/src/presentation/output_generator/plain_text_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class CliOutputGenerator extends PlainTextOutputGenerator {
  const CliOutputGenerator({
    required ColorizeCliText super.colorizeCliText,
    required super.print,
    required super.tableBuilder,
    required super.userOptions,
  });

  @override
  String? getSourceCodeHeader() => null;

  @override
  String? getSourceCodeFooter() => null;

  @override
  String? getSourceCodeBlocDivider() => "......\n\n";

  @override
  String getFileHeader(String filePath, int newLinesCount, int ignoredUntestedLines, int missingTestsLines) {
    final ignoredText = ignoredUntestedLines > 0
        ? colorizeText("$ignoredUntestedLines untested and ignored", ColorizeCliText.ignoredUntestedCodeColor)
        : null;
    final untestedText =
        missingTestsLines > 0 ? "${colorizeText("$missingTestsLines lines missing tests", TextColor.red)}\n" : null;

    return "${colorizeText(filePath, missingTestsLines > 0 ? TextColor.yellow : TextColor.noColor)}"
        " (${colorizeCliText!("+$newLinesCount", TextColor.green)})"
        "${ignoredText != null || untestedText != null ? "\n ┗━▶" : ""}"
        "${ignoredText != null ? " $ignoredText" : ""}"
        "${ignoredText != null && untestedText != null ? ", " : " "}"
        "${untestedText ?? ""}";
  }

  @override
  String? getLine(String line, int lineNumber, bool isANewLine, bool isUntested) {
    if (isANewLine && isUntested) {
      return "${colorizeCliText!("[$lineNumber]: ${line.replaceFirst("+", "→")}", TextColor.red)}\n";
    } else {
      return " $lineNumber : $line\n";
    }
  }

  @override
  String formatFileHeader(String text) => text;
}
