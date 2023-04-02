import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:pull_request_coverage/src/data/io/repository/io_repository_impl.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/arg_data_source.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/options_getters.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/yaml_data_source.dart';
import 'package:pull_request_coverage/src/data/user_options/user_options_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_exit_code.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_file_from_project.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/should_analyze_this_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/should_analyze_this_line.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/remove_git_root_relative_path.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncoverd_file_lines.dart';
import 'package:pull_request_coverage/src/domain/io/use_case/read_line_from_stdin.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_options_args.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/cli_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/get_result_table.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/markdown_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/plain_text_output_generator.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/table_builder.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_warnings_for_unexpected_file_structre.dart';

UserOptions _getOrFailUserOptions(List<String> arguments, FileSystem fileSystem) {
  final UserOptionsRepository argsRepository = UserOptionsRepositoryImpl(
    argDataSource: ArgDataSource(ArgParser(), UserOptionsArgs.options),
    yamlDataSource: YamlDataSource(),
    argGetters: OptionsGetters(),
    fileSystem: fileSystem,
  );
  final userOptions = argsRepository.getUserOptions(arguments);
  if (userOptions is ResultSuccess<UserOptions>) {
    return userOptions.data;
  } else {
    userOptions as ResultError<UserOptions>;
    print("Error parsing params: ${userOptions.message}");
    exit(ExitCode.error);
  }
}

Future<List<String>> _getOrFailLcovLines(String filePath, FileSystem fileSystem) async {
  try {
    final lines = await fileSystem.file(filePath).readAsLines();
    return lines;
  } catch (e) {
    print("Error reading lcov.info file: $e");
    print("\tDid you run `flutter test --coverage`?");
    exit(ExitCode.error);
  }
}

PlainTextOutputGenerator _getOutputGenerator(UserOptions userOptions, ColorizeCliText colorizeText) {
  final getResultTable = GetResultTable(TableBuilder(), colorizeText, userOptions);
  switch (userOptions.outputMode) {
    case OutputMode.cli:
      return CliOutputGenerator(
        colorizeText: colorizeText,
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

Future<void> main(List<String> arguments) async {
  final fileSystem = LocalFileSystem();
  final userOptions = _getOrFailUserOptions(arguments, fileSystem);
  final ioRepository = IoRepositoryImpl(
    fileSystem: fileSystem,
    stdin: stdin,
    stdinTimeout: userOptions.stdinTimeout,
  );
  final gitRootRelativePath = await ioRepository.getGitRootRelativePath();
  final lcovLines = await _getOrFailLcovLines(userOptions.lcovFilePath, fileSystem);
  final colorizeText = ColorizeCliText(userOptions.useColorfulOutput && userOptions.outputMode == OutputMode.cli);
  final outputGenerator = _getOutputGenerator(userOptions, colorizeText);

  PrintWarningsForUnexpectedFileStructure(print, colorizeText)(
    gitRootRelativePath: gitRootRelativePath,
    isLibDirPresent: await ioRepository.doesLibDirectoryExist(),
  );

  final analyzeUseCase = Analyze(
    parseGitDiff: ParseGitDiff(RemoveGitRootRelativePath(gitRootRelativePath)),
    forEachFileOnGitDiff: ForEachFileOnGitDiff(ReadLineFromStdin(ioRepository).call),
    lcovLines: lcovLines,
    shouldAnalyzeThisFile: ShouldAnalyzeThisFile(userOptions),
    setUncoveredLines: SetFileLineResultData(ShouldAnalyzeThisLine(userOptions.lineFilters)),
    getUncoveredFileLines: GetUncoveredFileLines(),
    outputGenerator: outputGenerator,
    isAFileFromProject: IsAFileFromProject(),
  );

  final result = await analyzeUseCase();

  print(outputGenerator.getReport(result));

  exit(GetExitCode()(result, userOptions));
}
