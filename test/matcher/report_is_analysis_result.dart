import 'package:pull_request_coverage/src/domain/analyzer/models/report.dart';
import 'package:test/expect.dart';

class ReportIsAnalysisResult extends Matcher {
  final Matcher? matcher;

  const ReportIsAnalysisResult({this.matcher});

  @override
  Description describe(Description description) {
    description.add("Item is Analysis Result and");
    matcher?.describe(description);
    return description;
  }

  @override
  bool matches(item, Map matchState) {
    final matcher = this.matcher;
    final report = item;
    if (report is Report) {
      return report.when(
        isAnalysisResult: (data) {
          if (matcher != null) {
            return matcher.matches(data, matchState);
          } else {
            return true;
          }
        },
        isFileReport: (data) => false,
      );
    } else {
      return false;
    }
  }
}
