import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';

abstract class OutputGenerator {
  Future<void> addFileReport(FileReport report);

  Future<void> exit(AnalysisResult analysisResult);
}
