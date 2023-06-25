import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/get_result_table.dart';

class CliOutputGenerator implements OutputGenerator {
  final UserOptions userOptions;
  final ColorizeText colorizeText;
  final GetResultTable getResultTable;
  final void Function(String message) print;

  CliOutputGenerator({
    required this.userOptions,
    required this.colorizeText,
    required this.getResultTable,
    required this.print,
  });

  final _missingTestFilesReport = StringBuffer();

  String? _getLine(FileLine fileLine) {
    if (fileLine.isNew && fileLine.isTestMissing) {
      return colorizeText("[${fileLine.lineNumber}]: ${fileLine.code.replaceFirst("+", "→")}", TextColor.red);
    } else {
      return " ${fileLine.lineNumber} : ${fileLine.code}";
    }
  }

  String _getFileHeader(FileReport fileReport) {
    final ignoredText = fileReport.untestedAndIgnoredLines > 0
        ? colorizeText(
            "${fileReport.untestedAndIgnoredLines} untested and ignored", ColorizeText.ignoredUntestedCodeColor)
        : null;
    final untestedText = fileReport.linesMissingTestsCount > 0
        ? "${colorizeText("${fileReport.linesMissingTestsCount} lines missing tests", TextColor.red)}\n"
        : null;

    return "${colorizeText(fileReport.filePath, fileReport.linesMissingTestsCount > 0 ? TextColor.yellow : TextColor.noColor)}"
        " (${colorizeText("+${fileReport.newLinesCount}", TextColor.green)})"
        "${ignoredText != null || untestedText != null ? "\n ┗━▶" : ""}"
        "${ignoredText != null ? " $ignoredText" : ""}"
        "${ignoredText != null && untestedText != null ? ", " : " "}"
        "${untestedText ?? ""}";
  }

  @override
  void addFileReport(FileReport fileReport) {
    final stringBuffer = StringBuffer();
    if (fileReport.linesMissingTestsCount > 0 || userOptions.reportFullyCoveredFiles) {
      stringBuffer.write(_getFileHeader(fileReport));
    }

    if (userOptions.showUncoveredCode && fileReport.linesMissingTestsCount > 0) {
      for (int i = 0; i < fileReport.chunks.length; i++) {
        final chunk = fileReport.chunks[i];
        if (i > 0) {
          stringBuffer.write("......\n\n");
        }
        for (final line in chunk) {
          stringBuffer.writeln(_getLine(line));
        }
      }
      _missingTestFilesReport.writeln(stringBuffer.toString());
    } else {
      if (stringBuffer.isNotEmpty) {
        print(stringBuffer.toString());
      }
    }
  }

  @override
  void terminate(AnalysisResult analysisResult) {
    if (_missingTestFilesReport.isNotEmpty) {
      print(_missingTestFilesReport.toString());
    }
    if (analysisResult.linesMissingTests == 0 && userOptions.fullyTestedMessage != null) {
      print(userOptions.fullyTestedMessage.toString());
    } else {
      print(getResultTable(userOptions, analysisResult));
    }
  }
}
