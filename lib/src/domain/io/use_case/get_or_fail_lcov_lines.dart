import 'dart:io';
import 'package:file/file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';

class GetOrFailLcovLines {
  final OutputGenerator outputGenerator;

  const GetOrFailLcovLines(this.outputGenerator);

  Future<List<String>> call(String filePath, FileSystem fileSystem) async {
    try {
      final lines = await fileSystem.file(filePath).readAsLines();
      return lines;
    } catch (e, s) {
      outputGenerator.printFatalError(
        "Error reading lcov.info file: $e\n\tDid you run `flutter test --coverage`?",
        e,
        s,
      );
      exit(ExitCode.error);
    }
  }
}
