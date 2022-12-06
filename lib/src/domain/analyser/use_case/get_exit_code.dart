import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyser/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

class GetExitCode {
  int call(AnalysisResult analysisResult, UserOptions userOptions) {
    if (userOptions.minimumCoverageRate != null && analysisResult.coverageRate < (userOptions.minimumCoverageRate! / 100)) {
      return ExitCode.testFail;
    }

    if (userOptions.maximumUncoveredLines != null && analysisResult.totalOfUncoveredNewLines > userOptions.maximumUncoveredLines!) {
      return ExitCode.testFail;
    }

    return ExitCode.noErrorsFounds;
  }
}
