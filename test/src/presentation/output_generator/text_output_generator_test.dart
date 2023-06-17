import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/cli_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/markdown_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/output_generator.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/get_result_table.dart';
import 'package:test/test.dart';

void main() {
  void testGenerator(
    String description,
    UserOptions userOptions,
    void Function(OutputGenerator generator, StringBuffer output) testFunction, {
    ColorizeText colorizeText = const FakeColorizeText(),
    GetResultTable getResultTable = const FakeGetResultTable(),
  }) {
    test("`$description` on CLI output generator", () {
      final output = StringBuffer();
      final generator = CliOutputGenerator(
        userOptions: userOptions,
        colorizeText: colorizeText,
        getResultTable: getResultTable,
        print: (String message) => output.write(message),
      );
      testFunction(generator, output);
    });

    test("`$description` on Markdown output generator", () {
      final output = StringBuffer();
      final generator = MarkdownOutputGenerator(
        userOptions: userOptions,
        getResultTable: getResultTable,
        print: (String message) => output.write(message),
      );
      testFunction(generator, output);
    });
  }

  group("When `fullyTestedMessage` is set", () {
    const message = "ææææ";
    group("And there is no missing tests", () {
      const result = AnalysisResult(
        linesThatShouldBeTested: 12,
        linesMissingTests: 0,
        untestedIgnoredLines: 0,
        linesMissingTestsThreshold: null,
        coverageRateThreshold: null,
      );

      testGenerator(
        "show its message",
        UserOptions(fullyTestedMessage: message),
        (generator, output) {
          generator.terminate(result);

          expect(output.toString(), contains(message));
        },
      );

      testGenerator(
        "do not show table",
        UserOptions(fullyTestedMessage: message),
        (generator, output) {
          generator.terminate(result);

          expect(output.toString(), isNot(contains(FakeGetResultTable.table)));
        },
      );
    });

    group("And there are missing tests", () {
      const result = AnalysisResult(
        linesThatShouldBeTested: 12,
        linesMissingTests: 1,
        untestedIgnoredLines: 0,
        linesMissingTestsThreshold: null,
        coverageRateThreshold: null,
      );

      testGenerator(
        "do not show custom message",
        UserOptions(fullyTestedMessage: message),
        (generator, output) {
          generator.terminate(result);

          expect(output.toString(), isNot(contains(message)));
        },
      );

      testGenerator(
        "show table",
        UserOptions(fullyTestedMessage: message),
        (generator, output) {
          generator.terminate(result);

          expect(output.toString(), contains(FakeGetResultTable.table));
        },
      );
    });
  });

  
}

class FakeGetResultTable implements GetResultTable {
  const FakeGetResultTable();

  static const table = "eruighfweiuyr weiurgy weyurg weuyrg wueyrg uwyerg iuewrg";

  @override
  String call(UserOptions userOptions, AnalysisResult analysisResult) => table;
}

class FakeColorizeText implements ColorizeText {
  const FakeColorizeText();

  @override
  String call(String text, TextColor color) => text;
}
