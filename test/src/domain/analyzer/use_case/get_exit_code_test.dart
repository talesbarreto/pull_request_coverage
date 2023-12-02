import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_exit_code.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/approval_requirement.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
import 'package:test/test.dart';

void main() {
  const exitCode = GetExitCode();
  group("when `ApprovalRequirement` is set to `linesAndRate`", () {
    group("approve when", () {
      test("coverage rate is 90, limit is 80. Uncovered lines is 4 and its limit is 15", () {
        final settings = UserSettings(
          minimumCoverageRate: 80,
          maximumUncoveredLines: 15,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.noErrorsFounds);
      });

      test("coverage rate is 90, limit is 80. Uncovered lines is 4 and there is no line limit", () {
        final settings = UserSettings(
          minimumCoverageRate: 80,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.noErrorsFounds);
      });

      test(" Uncovered lines is 15, its limit is 16 and there is no rate limit", () {
        final settings = UserSettings(
          maximumUncoveredLines: 16,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 9100,
          linesMissingTests: 15,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.noErrorsFounds);
      });
    });

    group("fail when", () {
      test("coverage rate is 90, limit is 90. Uncovered lines is 10 and its limit is 9", () {
        final settings = UserSettings(
          minimumCoverageRate: 90,
          maximumUncoveredLines: 9,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.testFail);
      });

      test("coverage rate is 84, limit is 80. Uncovered lines is 16 and its limit is 15", () {
        final settings = UserSettings(
          minimumCoverageRate: 80,
          maximumUncoveredLines: 15,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 16,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.testFail);
      });

      test("coverage rate is 84, limit is 85. Uncovered lines is 16 and there is no line limit", () {
        final settings = UserSettings(
          minimumCoverageRate: 85,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 16,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.testFail);
      });

      test("Uncovered lines is 10, limit is 9 and there is no rate limit", () {
        final settings = UserSettings(
          maximumUncoveredLines: 9,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.testFail);
      });
    });
  });

  group("when `ApprovalRequirement` is set to `linesOrRate`", () {
    group("approve when", () {
      test("coverage rate is 90, limit is 80. Uncovered lines is 4 and its limit is 15", () {
        final settings = UserSettings(
          minimumCoverageRate: 80,
          maximumUncoveredLines: 15,
          approvalRequirement: ApprovalRequirement.linesOrRate,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.noErrorsFounds);
      });

      test("coverage rate is 90, limit is 80. Uncovered lines is 4 and there is no line limit", () {
        final settings = UserSettings(
          minimumCoverageRate: 80,
          approvalRequirement: ApprovalRequirement.linesOrRate,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.noErrorsFounds);
      });

      test("coverage rate is 90, limit is 90. Uncovered lines is 10 and its limit is 9", () {
        final settings = UserSettings(
          minimumCoverageRate: 90,
          maximumUncoveredLines: 9,
          approvalRequirement: ApprovalRequirement.linesOrRate,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.noErrorsFounds);
      });

      test("Uncovered lines is 15, its limit is 16 and there is no rate limit", () {
        final settings = UserSettings(
          maximumUncoveredLines: 16,
          approvalRequirement: ApprovalRequirement.linesOrRate,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 9100,
          linesMissingTests: 15,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.noErrorsFounds);
      });
    });

    group("fail when", () {
      test("coverage rate is 90, limit is 91. Uncovered lines is 10 and its limit is 3", () {
        final settings = UserSettings(
          minimumCoverageRate: 91,
          maximumUncoveredLines: 3,
          approvalRequirement: ApprovalRequirement.linesOrRate,
        );
        final result = AnalysisResult(
          linesThatShouldBeTested: 100,
          linesMissingTests: 10,
          untestedIgnoredLines: 0,
        );
        expect(exitCode(result, settings), ExitCode.testFail);
      });
    });
  });
}
