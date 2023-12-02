import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/approval_requirement.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';

class GetExitCode {
  const GetExitCode();

  int call(AnalysisResult analysisResult, UserSettings userSettings) {
    final minimumCoverageFailRateIsSet = userSettings.minimumCoverageRate != null;
    final maximumUncoveredLinesFailIsSet = userSettings.maximumUncoveredLines != null;

    final minimumCoverageFail =
        minimumCoverageFailRateIsSet && analysisResult.coverageRate < (userSettings.minimumCoverageRate! / 100);
    final maximumUncoveredLinesFail =
        maximumUncoveredLinesFailIsSet && analysisResult.linesMissingTests > userSettings.maximumUncoveredLines!;

    if (userSettings.approvalRequirement == ApprovalRequirement.linesOrRate &&
        minimumCoverageFailRateIsSet &&
        maximumUncoveredLinesFailIsSet) {
      return maximumUncoveredLinesFail && minimumCoverageFail ? ExitCode.testFail : ExitCode.noErrorsFounds;
    }
    return maximumUncoveredLinesFail || minimumCoverageFail ? ExitCode.testFail : ExitCode.noErrorsFounds;
  }
}
