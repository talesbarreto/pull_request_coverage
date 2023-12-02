import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_emoji.dart';

class CliOutputGenerator implements OutputGenerator {
  final UserSettings userSettings;
  final ColorizeText colorizeText;
  final GetResultTable getResultTable;
  final PrintEmoji printEmoji;
  final void Function(String message) print;

  CliOutputGenerator({
    required this.userSettings,
    required this.colorizeText,
    required this.getResultTable,
    required this.printEmoji,
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
    final filePath = colorizeText(
      fileReport.filePath,
      fileReport.linesMissingTestsCount > 0 ? TextColor.yellow : TextColor.noColor,
    );

    final hasIgnoredUntestedLines = fileReport.untestedAndIgnoredLines > 0;
    final hasMissingTestLines = fileReport.linesMissingTestsCount > 0;

    final newLinesCount =
        fileReport.newLinesCount > 0 ? "(${colorizeText("+${fileReport.newLinesCount}", TextColor.green)})" : "(0)";

    final ignoredText = hasIgnoredUntestedLines
        ? colorizeText(
            printEmoji(
              "${OutputGenerator.skipEmoji} ${fileReport.untestedAndIgnoredLines}",
              "~ ${fileReport.untestedAndIgnoredLines} ignored",
            ),
            ColorizeText.ignoredUntestedCodeColor,
          )
        : "";

    final untestedText = hasMissingTestLines
        ? "${colorizeText(
            "${fileReport.linesMissingTestsCount} lines missing tests",
            TextColor.red,
          )}\n"
        : null;

    final surroundingEmojis = OutputGenerator.getFileHeaderSurroundingEmojis(
      printEmoji: printEmoji,
      hasMissingTestLines: hasMissingTestLines,
      hasIgnoredUntestedLines: hasIgnoredUntestedLines,
      hasNewLines: fileReport.newLinesCount > 0,
    );

    return "${surroundingEmojis.prefix}$filePath $newLinesCount $ignoredText${surroundingEmojis.suffix}"
        "${untestedText != null ? "\n ┗━▶ $untestedText" : ""}";
  }

  @override
  void addFileReport(FileReport fileReport) {
    final stringBuffer = StringBuffer();
    if (fileReport.linesMissingTestsCount > 0 || userSettings.reportFullyCoveredFiles) {
      stringBuffer.write(_getFileHeader(fileReport));
    }

    if (userSettings.showUncoveredCode && fileReport.linesMissingTestsCount > 0) {
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
    if (analysisResult.linesMissingTests == 0 && userSettings.fullyTestedMessage != null) {
      print(userSettings.fullyTestedMessage.toString());
    } else {
      print(getResultTable(userSettings, analysisResult));
    }
  }
}
