import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';

class PersistentOutputGenerator implements OutputGenerator {
  List<FileReport> fileReports = [];
  AnalysisResult? analysisResult;

  @override
  Future<void> addFileReport(FileReport report) async {
    fileReports.add(report);
  }

  @override
  Future<void> exit(AnalysisResult analysisResult) async {
    this.analysisResult = analysisResult;
  }
}
