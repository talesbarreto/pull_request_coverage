import 'dart:io';
import 'package:file/file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';
import 'package:pull_request_coverage/src/presentation/logger/logger.dart';

class GetOrFailLcovLines {
  Future<List<String>> call(String filePath, FileSystem fileSystem) async {
    try {
      final lines = await fileSystem.file(filePath).readAsLines();
      return lines;
    } catch (e, s) {
      logger.log(
        tag: "GetOrFailLcovLines",
        message: "Error reading lcov.info file: $e",
        stackTrace: s,
        level: LogLevel.error,
      );
      logger.printWarning("Error reading lcov.info file: $e. Did you run `flutter test --coverage`?");
      exit(ExitCode.error);
    }
  }
}
