import 'package:file/file.dart';
import 'package:pull_request_coverage/src/data/io/repository/file_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/io/repository/io_repository.dart';
import 'package:pull_request_coverage/src/domain/io/use_case/get_or_fail_lcov_lines.dart';

class IoModule {
  const IoModule._();
  static IoRepository provideIoRepository({
    required Duration stdinTimeout,
    required FileSystem fileSystem,
    Stream<String>? stdinStream,
  }) {
    return FileRepositoryImpl(
      fileSystem: fileSystem,
      stdinTimeout: stdinTimeout,
    );
  }

  static GetOrFailLcovLines provideGetOrFailLcovLines() {
    return GetOrFailLcovLines();
  }
}
