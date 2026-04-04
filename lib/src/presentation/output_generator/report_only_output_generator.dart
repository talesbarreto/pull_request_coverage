import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/get_result_table.dart';

class ReportOnlyOutputGenerator implements OutputGenerator {
  final UserSettings userSettings;
  final GetResultTable getResultTable;
  final void Function(String message) print;

  ReportOnlyOutputGenerator({
    required this.userSettings,
    required this.getResultTable,
    required this.print,
  });

  @override
  void addFileReport(FileReport report) {
    // In report-only mode, we suppress all intermediate output
    // and only show the final summary table
  }

  @override
  void terminate(AnalysisResult analysisResult) {
    if (analysisResult.linesMissingTests == 0 && userSettings.fullyTestedMessage != null) {
      print(userSettings.fullyTestedMessage.toString());
    } else {
      print(getResultTable(userSettings, analysisResult));
    }
  }
}
