import 'package:test/test.dart';

import 'integration_test_set.dart';

void main() {
  const lcovFileParam = ["--lcov-file", "input_samples/sample1/lcov.info"];
  const diffFilePath = "input_samples/sample1/sample1.diff";
  group("when running with default settings", () {
    test("report 22 lines that should be tested", () async {
      final testSet = await IntegrationTestSet.withSet(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await testSet.analyze();
      expect(result.totalOfNewLines, 26);
    });

    test("report 8 untested new lines", () async {
      final testSet = await IntegrationTestSet.withSet(
        arguments: lcovFileParam,
        diffFilePath: diffFilePath,
      );
      final result = await testSet.analyze();
      expect(result.totalOfUncoveredNewLines, 8);
    });
  });

  group("When `override` annotation is ignored", () {
    test("report 23 lines that should be tested", () async {
      final testSet = await IntegrationTestSet.withSet(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await testSet.analyze();
      expect(result.totalOfNewLines, 23);
    });
    test("report 3 untested ignored lines", () async {
      final testSet = await IntegrationTestSet.withSet(
        arguments: [...lcovFileParam, "--ignore-lines", "^.*@override.*\$"],
        diffFilePath: diffFilePath,
      );
      final result = await testSet.analyze();
      expect(result.totalOfIgnoredLinesMissingTests, 3);
    });
  });
}
