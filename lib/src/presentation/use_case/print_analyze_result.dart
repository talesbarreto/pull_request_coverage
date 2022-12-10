import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

class PrintAnalysisResult {
  final void Function(String message) print;
  final ColorizeText colorizeText;

  const PrintAnalysisResult(this.print, this.colorizeText);

  void call(AnalysisResult analysisResult, UserOptions userOptions) {
    if (analysisResult.totalOfNewLines == 0) {
      print("This pull request has no new lines 🤔");
      return;
    }

    final outputBuilder = StringBuffer();

    final minimumCoverageRate = userOptions.minimumCoverageRate;
    final minimumCoveredLines = userOptions.maximumUncoveredLines;

    outputBuilder.writeln("------------------------------------");
    outputBuilder.writeln("After ignoring excluded files, this pull request has:");
    outputBuilder.write("\t- ${analysisResult.totalOfNewLines} new lines, ");
    if (analysisResult.totalOfUncoveredNewLines == 0) {
      outputBuilder.writeln(colorizeText("ALL of them are covered by tests", TextColor.green));
    } else {
      outputBuilder.write(colorizeText("${analysisResult.totalOfUncoveredNewLines} of them are NOT covered by tests. ", TextColor.yellow));
      if (minimumCoveredLines != null) {
        if (analysisResult.totalOfUncoveredNewLines > minimumCoveredLines) {
          outputBuilder.write(colorizeText("You can only have up to $minimumCoveredLines uncovered lines", TextColor.red));
        } else {
          outputBuilder.write(colorizeText("But....it's enough to pass the test =D", TextColor.green));
        }
      }
      outputBuilder.writeln();
    }

    outputBuilder.write("\t- ${analysisResult.coverageRate * 100}% of coverage. ");

    if (minimumCoverageRate != null) {
      if (analysisResult.coverageRate < (minimumCoverageRate / 100)) {
        outputBuilder.write(colorizeText("You need at least $minimumCoverageRate% of coverage", TextColor.red));
      } else {
        outputBuilder.write(colorizeText("This is above the limit of $minimumCoverageRate%", TextColor.green));
      }
    } else {
      outputBuilder.writeln();
    }
    print(outputBuilder.toString());
  }
}
