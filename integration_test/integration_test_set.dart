import 'dart:convert';
import 'dart:io';

import 'package:file/local.dart';
import 'package:pull_request_coverage/src/di/analyze_module.dart';
import 'package:pull_request_coverage/src/di/io_module.dart';
import 'package:pull_request_coverage/src/di/user_options_module.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/user_options/use_case/get_or_fail_user_options.dart';

import 'persistent_output_generator.dart';

class IntegrationTestSet {
  final PersistentOutputGenerator persistentOutputGenerator;
  final Analyze analyze;

  const IntegrationTestSet({
    required this.analyze,
    required this.persistentOutputGenerator,
  });

  static Future<IntegrationTestSet> withSet({
    required String diffFilePath,
    List<String> arguments = const [],
  }) async {
    final fileSystem = LocalFileSystem();
    final persistentOutputGenerator = PersistentOutputGenerator();
    final getOrFailLcovLines = IoModule.provideGetOrFailLcovLines(outputGenerator: persistentOutputGenerator);

    final userOptions = GetOrFailUserOptions(
      userOptionsRepository: UserOptionsModule.provideUserOptionsRepository(fileSystem: fileSystem),
    ).call(arguments);

    return IntegrationTestSet(
      analyze: await AnalyzeModule.provideAnalyzeUseCase(
        userOptions: userOptions,
        lcovLines: await getOrFailLcovLines(userOptions.lcovFilePath, fileSystem),
        ioRepository: IoModule.provideIoRepository(
          fileSystem: fileSystem,
          stdinTimeout: userOptions.stdinTimeout,
          stdinStream: File(diffFilePath).openRead().transform(utf8.decoder).transform(LineSplitter()).asBroadcastStream(),
        ),
        outputGenerator: persistentOutputGenerator,
      ),
      persistentOutputGenerator: persistentOutputGenerator,
    );
  }
}
