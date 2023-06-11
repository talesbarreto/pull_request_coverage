import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/get_result_table.dart';

class MarkdownOutputGenerator implements OutputGenerator {
  final UserOptions userOptions;
  final GetResultTable getResultTable;
  final void Function(String message) print;

  MarkdownOutputGenerator({
    required this.userOptions,
    required this.getResultTable,
    required this.print,
  });

  final _missingTestFilesReport = StringBuffer();
  final _testedFilesReport = StringBuffer();

  String? _getSourceCodeHeader() => userOptions.markdownMode == MarkdownMode.diff ? "```diff\n" : "```dart\n";

  String? _getSourceCodeFooter() => "```";

  String? _getSourceCodeBlocDivider() {
    return "```\n${_getSourceCodeHeader()}";
  }

  String formatFileHeader(String text) => " - `$text";

  String? _getLine(FileLine fileLine) {
    if (fileLine.isNew && fileLine.isTestMissing) {
      if (userOptions.markdownMode == MarkdownMode.diff) {
        return "- ${fileLine.lineNumber}: ${fileLine.code}";
      } else {
        return "${fileLine.code}\t// <- MISSING TEST AT LINE ${fileLine.lineNumber}";
      }
    } else {
      if (userOptions.markdownMode == MarkdownMode.diff) {
        return "  ${fileLine.lineNumber}: ${fileLine.code}";
      } else {
        return fileLine.code;
      }
    }
  }

  String _getFileHeader(FileReport fileReport) {
    final String? ignoredText;
    final String? untestedText;
    final pathHeader = fileReport.linesMissingTestsCount > 0 ? "##### " : "";

    if (fileReport.untestedAndIgnoredLines > 0) {
      ignoredText = "${fileReport.untestedAndIgnoredLines} untested and ignored";
    } else {
      ignoredText = null;
    }
    if (fileReport.linesMissingTestsCount > 0) {
      untestedText = "${fileReport.linesMissingTestsCount} lines missing tests";
    } else {
      untestedText = null;
    }

    return "$pathHeader`${fileReport.filePath}` (+${fileReport.newLinesCount})"
        "${ignoredText != null ? " / _${ignoredText}_ " : ""}"
        "${untestedText != null ? " / **$untestedText** " : ""}";
  }

  @override
  Future<void> addFileReport(FileReport fileReport) async {
    final stringBuffer = StringBuffer();
    if (fileReport.linesMissingTestsCount > 0 || userOptions.reportFullyCoveredFiles) {
      stringBuffer.writeln(_getFileHeader(fileReport));
    }
    if (userOptions.showUncoveredCode && fileReport.linesMissingTestsCount > 0) {
      stringBuffer.writeln(_getSourceCodeHeader());
      for (int i = 0; i < fileReport.chunks.length; i++) {
        final chunk = fileReport.chunks[i];
        if (i > 0) {
          stringBuffer.write(_getSourceCodeBlocDivider());
        }
        for (final line in chunk) {
          stringBuffer.writeln(_getLine(line));
        }
      }
      stringBuffer.writeln(_getSourceCodeFooter());
      _missingTestFilesReport.writeln(stringBuffer.toString());
    } else {
      _testedFilesReport.writeln(stringBuffer.toString());
    }
  }

  @override
  Future<void> exit(AnalysisResult analysisResult) async {
    print(_testedFilesReport.toString());
    print(_missingTestFilesReport.toString());
    print(getResultTable(userOptions, analysisResult));
  }
}
