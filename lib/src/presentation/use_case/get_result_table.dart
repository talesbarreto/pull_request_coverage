import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/table_builder.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';

class GetResultTable {
  final TableBuilder tableBuilder;
  final ColorizeText colorizeText;

  const GetResultTable({
    required this.tableBuilder,
    required this.colorizeText,
  });

  String call(UserOptions userOptions, AnalysisResult analysisResult) {
    final stringBuffer = StringBuffer();

    final maximumUncoveredLines = userOptions.maximumUncoveredLines;
    final minimumCoverageRate = userOptions.minimumCoverageRate;

    final coverage = (analysisResult.coverageRate * 100);
    final coverageTxt = coverage.isNaN ? "-" : "${coverage.toStringAsFixed(userOptions.fractionalDigits)}%";

    String result(bool success) =>
        success ? colorizeText("Success", TextColor.green) : colorizeText("FAIL", TextColor.red);

    final linesResult =
        maximumUncoveredLines == null ? "-" : result(analysisResult.linesMissingTests <= maximumUncoveredLines);
    final lineThreshold = maximumUncoveredLines == null ? "-" : "$maximumUncoveredLines";
    final rateResult = minimumCoverageRate == null || analysisResult.coverageRate.isNaN
        ? "-"
        : result(analysisResult.coverageRate >= (minimumCoverageRate / 100));
    final rateThreshold = minimumCoverageRate == null ? "-" : "$minimumCoverageRate%";

    final ignoredUntestedLinesText = colorizeText(
      analysisResult.untestedIgnoredLines.toString(),
      ColorizeText.ignoredUntestedCodeColor,
    );

    if (analysisResult.linesMissingTests == 0 && userOptions.fullyTestedMessage != null) {
      stringBuffer.write(userOptions.fullyTestedMessage.toString());
    } else {
      tableBuilder
        ..setHeader(["Report", "Current value", "Threshold", ""])
        ..addLine(["Lines that should be tested", analysisResult.linesThatShouldBeTested.toString(), "", ""])
        ..addLine(["Ignored untested lines", ignoredUntestedLinesText, "", ""])
        ..addLine(["Lines missing tests", analysisResult.linesMissingTests.toString(), lineThreshold, linesResult])
        ..addLine(["Coverage rate", coverageTxt, rateThreshold, rateResult]);

      stringBuffer.write("\n${tableBuilder.build(userOptions.outputMode == OutputMode.markdown)}");
    }
    return stringBuffer.toString();
  }
}
