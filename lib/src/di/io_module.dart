import 'dart:convert';
import 'dart:io';
import 'package:file/file.dart';
import 'package:pull_request_coverage/src/data/io/repository/io_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/io/repository/io_repository.dart';
import 'package:pull_request_coverage/src/domain/io/use_case/get_or_fail_lcov_lines.dart';

class IoModule {
  const IoModule._();
  static IoRepository provideIoRepository({
    required Duration stdinTimeout,
    required FileSystem fileSystem,
    Stream<String>? stdinStream,
  }) {
    return IoRepositoryImpl(
      fileSystem: fileSystem,
      stdinStream:
          stdinStream ?? stdin.transform(utf8.decoder).transform<String>(const LineSplitter()).asBroadcastStream(),
      stdinTimeout: stdinTimeout,
    );
  }

  static GetOrFailLcovLines provideGetOrFailLcovLines() {
    return GetOrFailLcovLines();
  }
}
