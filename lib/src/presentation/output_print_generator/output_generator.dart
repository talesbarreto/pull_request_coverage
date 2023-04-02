import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';

abstract class OutputGenerator {
  void printFatalError(String msg, dynamic error, StackTrace? stackTrace);
  void addFile(FileDiff fileDiff);
  void setReport(AnalysisResult analysisResult);
  void printOutput();
}
