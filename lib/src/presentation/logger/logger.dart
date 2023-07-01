import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

Logger get logger => Logger._global;

class Logger {
  static Logger _global = const Logger();

  static Logger get global => _global;

  static void setGlobalLogger(Logger logger) => _global = logger;

  final LogLevel _logLevel;

  const Logger({
    LogLevel currentLogLevel = LogLevel.none,
  }) : _logLevel = currentLogLevel;

  void log({
    required String tag,
    required String message,
    LogLevel level = LogLevel.verbose,
    StackTrace? stackTrace,
  }) {
    assert(level != LogLevel.none);
    if (level.index <= _logLevel.index) {
      print("[$tag] $message");
    }
  }

  void printWarning(String msg) {
    print(msg);
  }
}
