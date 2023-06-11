import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';

class Report {
  final AnalysisResult? analysisResult;
  final FileReport? fileReport;

  const Report.analysisResult(this.analysisResult) : fileReport = null;

  const Report.fileReport(this.fileReport) : analysisResult = null;

  T when<T>({
    required T Function(AnalysisResult analysisResult) isAnalysisResult,
    required T Function(FileReport fileReport) isFileReport,
  }) {
    if (fileReport != null) {
      return isFileReport(fileReport!);
    }
    return isAnalysisResult(analysisResult!);
  }
}
