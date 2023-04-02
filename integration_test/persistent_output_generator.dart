import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';

class PersistentOutputGenerator implements OutputGenerator {
  List<FileDiff> diffs = [];
  AnalysisResult? analysisResult;

  @override
  void addFile(FileDiff fileDiff) {
    diffs.add(fileDiff);
  }

  @override
  void printFatalError(String msg, error, StackTrace? stackTrace) {
    // TODO: implement printFatalError
  }

  @override
  void printOutput() {
    // TODO: implement printOutput
  }

  @override
  void setReport(AnalysisResult analysisResult) {
    this.analysisResult = analysisResult;
  }
}
