import 'dart:async';

import 'package:pull_request_coverage/src/domain/io/repository/io_repository.dart';

class ReadLineFromStdin {
  final IoRepository ioRepository;

  const ReadLineFromStdin(this.ioRepository);

  Future<String?> call() => ioRepository.readStdinLine();
}
