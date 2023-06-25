import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/cli_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/markdown_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/table_builder.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_emoji.dart';

import '../presentation/output_generator/output_generator.dart';

class OutputGeneratorModule {
  const OutputGeneratorModule._();

  static OutputGenerator provideGenerator({
    required UserOptions userOptions,
    required ColorizeText colorizeText,
  }) {
    final printEmoji = PrintEmoji(userOptions.useEmojis);

    switch (userOptions.outputMode) {
      case OutputMode.cli:
        return CliOutputGenerator(
          colorizeText: colorizeText,
          userOptions: userOptions,
          print: print,
          printEmoji: printEmoji,
          getResultTable: GetResultTable(
            tableBuilder: TableBuilder(),
            colorizeText: colorizeText,
            printEmoji: printEmoji,
          ),
        );
      case OutputMode.markdown:
        return MarkdownOutputGenerator(
          userOptions: userOptions,
          print: print,
          getResultTable: GetResultTable(
            tableBuilder: TableBuilder(),
            colorizeText: colorizeText,
            printEmoji: printEmoji,
          ),
          printEmoji: printEmoji,
        );
    }
  }
}
