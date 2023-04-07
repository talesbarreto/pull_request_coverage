import 'dart:io';
import 'package:file/file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/presentation/logger/logger.dart';

class GetOrFailLcovLines {
  Future<List<String>> call(String filePath, FileSystem fileSystem) async {
    try {
      final lines = await fileSystem.file(filePath).readAsLines();
      return lines;
    } catch (e, s) {
      Logger.global
        ?..printError(
          origin: "Getting lcov.info lines",
          msg: "Error reading lcov.info file: $e",
          stackTrace: s,
          alwaysPrint: true,
        )
        ..printInfo(
          msg: 'Did you run `flutter test --coverage`?',
          alwaysPrint: true,
        );

      exit(ExitCode.error);
    }
  }
}
