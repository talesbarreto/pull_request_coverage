import 'dart:convert';
import 'dart:io';

import 'package:file/local.dart';
import 'package:pull_request_coverage/src/di/analyze_module.dart';
import 'package:pull_request_coverage/src/di/io_module.dart';
import 'package:pull_request_coverage/src/di/user_options_module.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/user_options/use_case/get_or_fail_user_options.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';

import 'persistent_output_generator.dart';

Future<Analyze> getAnalyzeForIntegrationTest({
  required String diffFilePath,
  List<String> arguments = const [],
  OutputGenerator? outputGenerator,
}) async {
  final fileSystem = LocalFileSystem();

  final userOptions = GetOrFailUserOptions(
    userOptionsRepository: UserOptionsModule.provideUserOptionsRepository(fileSystem: fileSystem),
  ).call(arguments);
  final outputGeneratorImpl = outputGenerator ?? PersistentOutputGenerator();
  final getOrFailLcovLines = IoModule.provideGetOrFailLcovLines();

  return AnalyzeModule.provideAnalyzeUseCase(
    userOptions: userOptions,
    lcovLines: await getOrFailLcovLines(userOptions.lcovFilePath, fileSystem),
    ioRepository: IoModule.provideIoRepository(
      fileSystem: fileSystem,
      stdinTimeout: userOptions.stdinTimeout,
      stdinStream: File(diffFilePath).openRead().transform(utf8.decoder).transform(LineSplitter()).asBroadcastStream(),
    ),
    outputGenerator: outputGeneratorImpl,
  );
}
