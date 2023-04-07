import 'package:test/test.dart';

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
      final result = await analyze();
      expect(result.linesShouldBeTested, 89);
    });

    test("report 6 lines missing test", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze();
      expect(result.linesMissingTests, 6);
    });
  });

  group("When `override` annotation is ignored", () {
    test("report 89 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze();
      expect(result.linesShouldBeTested, 89);
    });
    test("report 0 untested ignored lines", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze();
      expect(result.untestedIgnoredLines, 0);
    });
  });
}
