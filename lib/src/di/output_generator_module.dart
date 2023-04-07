import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/cli_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/markdown_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_generator/table_builder.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

import '../presentation/output_generator/output_generator.dart';

class OutputGeneratorModule {
  const OutputGeneratorModule._();

  static OutputGenerator providePlainTextOutputGenerator(UserOptions userOptions) {
    final colorizeText = ColorizeCliText(userOptions.useColorfulOutput && userOptions.outputMode == OutputMode.cli);
    final getResultTable = GetResultTable(TableBuilder(), colorizeText, userOptions);
    switch (userOptions.outputMode) {
      case OutputMode.cli:
        return CliOutputGenerator(
          colorizeCliText: colorizeText,
          userOptions: userOptions,
          getResultTable: getResultTable,
          print: print,
        );
      case OutputMode.markdown:
        return MarkdownOutputGenerator(
          userOptions: userOptions,
          getResultTable: getResultTable,
          print: print,
        );
    }
  }
}
