import 'package:file/file.dart';
import 'package:pull_request_coverage/src/data/file/repository/file_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/file/repository/file_repository.dart';
import 'package:pull_request_coverage/src/domain/file/use_case/get_or_fail_lcov_lines.dart';

class IoModule {
  const IoModule._();
  static FileRepository provideIoRepository({
    required Duration stdinTimeout,
    required FileSystem fileSystem,
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
