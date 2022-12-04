import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ReadLineFromStdin {
  static final Stream<String> _stdinLineStreamBroadcaster = stdin.transform(utf8.decoder).transform(const LineSplitter()).asBroadcastStream();

  /// Reads a single line from [stdin] asynchronously.
  Future<String?> call() async {
    try {
      final line = await _stdinLineStreamBroadcaster.first.timeout(Duration(seconds: 1));
      return line;
    } catch (e) {
      if (e is TimeoutException) {
        return null;
      } else {
        print("Error reading diff: $e");
      }
      return null;
    }
  }
}
