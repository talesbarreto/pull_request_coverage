import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';

abstract class OutputGenerator {
  void addFileReport(FileReport report);

  void terminate(AnalysisResult analysisResult);
}
