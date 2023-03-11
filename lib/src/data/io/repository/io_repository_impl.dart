import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pull_request_coverage/src/domain/io/repository/io_repository.dart';


class IoRepositoryImpl implements IoRepository {
  static final Stream<String> _stdinLineStreamBroadcaster =
      stdin.transform(utf8.decoder).transform(const LineSplitter()).asBroadcastStream();

  @override
  Future<String?> readStdinLine() async {
    try {
      final line = await _stdinLineStreamBroadcaster.first.timeout(Duration(seconds: 1));
      return line;
    } catch (e) {
      return null;
    }
  }
}
