import 'package:pull_request_coverage/src/domain/analyser/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/presentation/use_case/text_color.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

class PrintAnalysisResult {
  final void Function(String message) print;

  const PrintAnalysisResult(this.print);

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
    outputBuilder.write("\t✪ ${analysisResult.totalOfNewLines} new lines, ");
    if (analysisResult.totalOfUncoveredNewLines == 0) {
      outputBuilder.writeln(TextColor.colorize("ALL of them are covered by tests", TextColor.green));
    } else {
      outputBuilder.write(TextColor.colorize("${analysisResult.totalOfUncoveredNewLines} of them are NOT covered by tests. ", TextColor.yellow));
      if (minimumCoveredLines != null) {
        if (analysisResult.totalOfUncoveredNewLines > minimumCoveredLines) {
          outputBuilder.write(TextColor.colorize("You need at least $minimumCoveredLines covered lines", TextColor.red));
        } else {
          outputBuilder.write(TextColor.colorize("But....it's enough to pass the test 😉", TextColor.green));
        }
      }
      outputBuilder.writeln();
    }

    outputBuilder.write("\t✪ ${analysisResult.coverageRate * 100}% of coverage. ");

    if (minimumCoverageRate != null) {
      if (analysisResult.coverageRate < (minimumCoverageRate / 100)) {
        outputBuilder.write(TextColor.colorize("You need at least $minimumCoverageRate% of coverage", TextColor.red));
      } else {
        outputBuilder.write(TextColor.colorize("This is above the limit of $minimumCoverageRate%", TextColor.green));
      }
    } else {
      outputBuilder.writeln();
    }
    print(outputBuilder.toString());
  }
}
