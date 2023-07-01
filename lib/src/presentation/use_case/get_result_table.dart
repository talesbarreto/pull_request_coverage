import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/table_builder.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_emoji.dart';

class GetResultTable {
  final TableBuilder _tableBuilder;
  final ColorizeText _colorizeText;
  final PrintEmoji _printEmoji;

  const GetResultTable({
    required TableBuilder tableBuilder,
    required ColorizeText colorizeText,
    required PrintEmoji printEmoji,
  })  : _colorizeText = colorizeText,
        _printEmoji = printEmoji,
        _tableBuilder = tableBuilder;

  String call(UserOptions userOptions, AnalysisResult analysisResult) {
    final stringBuffer = StringBuffer();

    final maximumUncoveredLines = userOptions.maximumUncoveredLines;
    final minimumCoverageRate = userOptions.minimumCoverageRate;

    final coverage = (analysisResult.coverageRate * 100);
    final coverageTxt = coverage.isNaN ? "-" : "${coverage.toStringAsFixed(userOptions.fractionalDigits)}%";

    String result(bool success) => success
        ? _printEmoji(OutputGenerator.successEmoji, _colorizeText("Success", TextColor.green))
        : _printEmoji(OutputGenerator.failEmoji, _colorizeText("FAIL", TextColor.red));

    final linesResult =
        maximumUncoveredLines == null ? "-" : result(analysisResult.linesMissingTests <= maximumUncoveredLines);
    final lineThreshold = maximumUncoveredLines == null ? "-" : "$maximumUncoveredLines";
    final rateResult = minimumCoverageRate == null || analysisResult.coverageRate.isNaN
        ? "-"
        : result(analysisResult.coverageRate >= (minimumCoverageRate / 100));
    final rateThreshold = minimumCoverageRate == null ? "-" : "$minimumCoverageRate%";

    final ignoredUntestedLinesText = _colorizeText(
      analysisResult.untestedIgnoredLines.toString(),
      ColorizeText.ignoredUntestedCodeColor,
    );

    _tableBuilder
      ..setHeader(["Report", "Current value", "Threshold", ""])
      ..addLine(["Lines that should be tested", analysisResult.linesThatShouldBeTested.toString(), "", ""])
      ..addLine([
        "Ignored untested lines",
        ignoredUntestedLinesText,
        "",
        analysisResult.untestedIgnoredLines > 0 ? _printEmoji(OutputGenerator.skipEmoji, "") : ""
      ])
      ..addLine(["Lines missing tests", analysisResult.linesMissingTests.toString(), lineThreshold, linesResult])
      ..addLine(["Coverage rate", coverageTxt, rateThreshold, rateResult]);

    stringBuffer.write("\n${_tableBuilder.build(userOptions.outputMode == OutputMode.markdown)}");
    return stringBuffer.toString();
  }
}
