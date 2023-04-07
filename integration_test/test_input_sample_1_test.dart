import 'package:test/test.dart';

import 'integration_test_set.dart';

void main() {
  const lcovFileParam = ["--lcov-file", "input_samples/sample1/lcov.info"];
  const diffFilePath = "input_samples/sample1/sample1.diff";
  group("when running with default settings", () {
    test("report 22 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze();
      expect(result.linesShouldBeTested, 26);
    });

    test("report 8 untested new lines", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await analyze();
      expect(result.linesMissingTests, 8);
    });
  });

  group("When `override` annotation is ignored", () {
    test("report 23 lines that should be tested", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze();
      expect(result.linesShouldBeTested, 23);
    });
    test("report 3 untested ignored lines", () async {
      final analyze = await getAnalyzeForIntegrationTest(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await analyze();
      expect(result.untestedIgnoredLines, 3);
    });
  });
}
