import 'package:pull_request_coverage/src/domain/user_settings/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
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
    required UserSettings userSettings,
    required ColorizeText colorizeText,
  }) {
    final printEmoji = PrintEmoji(userSettings.useEmojis);

    switch (userSettings.outputMode) {
      case OutputMode.cli:
        return CliOutputGenerator(
          colorizeText: colorizeText,
          userSettings: userSettings,
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
          userSettings: userSettings,
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
