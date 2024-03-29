import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:test/test.dart';

import '../test/matcher/report_is_analysis_result.dart';
import 'shared/integration_test_set.dart';

/// The sample 3 was generated by `coverage` (for dart instead of Flutter). It created a lcov file using absolute paths
void main() {
  const lcovFileParam = ["--lcov-file", "input_samples/sample3/lcov.info"];
  const diffFilePath = "input_samples/sample3/git.diff";
  group("when running with default settings", () {
    test("report 102 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(result,
          ReportIsAnalysisResult(matcher: predicate<AnalysisResult>((p0) => p0.linesThatShouldBeTested == 102)));
    });

    test("report 26 lines missing test", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(result, ReportIsAnalysisResult(matcher: predicate<AnalysisResult>((p0) => p0.linesMissingTests == 26)));
    });
  });

  group("When `addLine` annotation is ignored", () {
    test("report 101 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*addLine.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(result,
          ReportIsAnalysisResult(matcher: predicate<AnalysisResult>((p0) => p0.linesThatShouldBeTested == 101)));
    });

    test("report 1 untested ignored lines", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*addLine.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze().toList();
      expect(
        result
            .firstWhere((element) => element.fileReport?.filePath.endsWith("get_result_table.dart") == true)
            .fileReport
            ?.untestedAndIgnoredLines,
        1,
      );
      expect(
        result.last,
        ReportIsAnalysisResult(matcher: predicate<AnalysisResult>((p0) => p0.untestedIgnoredLines == 1)),
      );
    });
  });
}
