import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:test/test.dart';
import '../test/matcher/report_is_analysis_result.dart';
import 'shared/integration_test_set.dart';

void main() {
  const lcovFileParam = ["--lcov-file", "input_samples/sample1/lcov.info"];
  const diffFilePath = "input_samples/sample1/git.diff";
  group("when running with default settings", () {
    test("report 89 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );

      final result = await analyze().last;
      expect(
          result,
          ReportIsAnalysisResult(
              matcher: predicate<AnalysisResult>(
            (e) => e.linesThatShouldBeTested == 89,
          )));
    });

    test("report 6 lines missing tests", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(
        result,
        ReportIsAnalysisResult(
          matcher: predicate<AnalysisResult>((e) => e.linesMissingTests == 6),
        ),
      );
    });
  });

  group("When `override` annotation is ignored", () {
    test("report 89 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(
        result,
        ReportIsAnalysisResult(
          matcher: predicate<AnalysisResult>((e) => e.linesThatShouldBeTested == 89),
        ),
      );
    });

    test("report 0 untested ignored lines", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze().last;
      expect(
        result,
        ReportIsAnalysisResult(
          matcher: predicate<AnalysisResult>((e) => e.untestedIgnoredLines == 0),
        ),
      );
    });
  });
}
