import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';

abstract class OutputGenerator {
  void addFile(FileDiff fileDiff);
  void setReport(AnalysisResult analysisResult);
  void printOutput();
}
