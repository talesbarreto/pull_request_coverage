import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:test/test.dart';
import '../test/matcher/report_is_analysis_result.dart';
import 'shared/integration_test_set.dart';

void main() {
  const lcovFileParam = ["--lcov-file", "input_samples/sample2/lcov.info"];
  const diffFilePath = "input_samples/sample2/git.diff";
  group("when running with default settings", () {
    test("report 22 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(result, ReportIsAnalysisResult(
        matcher: predicate<AnalysisResult>((p0) => p0.linesThatShouldBeTested == 26)
      ));
    });

    test("report 8 lines missing test", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(result, ReportIsAnalysisResult(
        matcher: predicate<AnalysisResult>((p0) => p0.linesMissingTests == 8)
      ));
    });
  });

  group("When `override` annotation is ignored", () {
    test("report 23 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(result, ReportIsAnalysisResult(
        matcher: predicate<AnalysisResult>((p0) => p0.linesThatShouldBeTested == 23)
      ));
    });
    test("report 3 untested ignored lines", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(result, ReportIsAnalysisResult(
        matcher: predicate<AnalysisResult>((p0) => p0.untestedIgnoredLines == 3)
      ));
    });
  });
}
