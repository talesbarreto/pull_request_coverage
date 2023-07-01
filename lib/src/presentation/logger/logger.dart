import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

Logger get logger => Logger._global;

class Logger {
  static Logger _global = const Logger();

  static Logger get global => _global;

  static void setGlobalLogger(Logger logger) => _global = logger;

  final LogLevel _currentLogLevel;

  const Logger({
    LogLevel logLevel = LogLevel.none,
  }) : _currentLogLevel = logLevel;

  void log({
    required String tag,
    required String message,
    LogLevel level = LogLevel.verbose,
    StackTrace? stackTrace,
  }) {
    assert(level != LogLevel.none);
    if (level.index <= _currentLogLevel.index) {
      print("\t[$tag] $message");
    }
  }

  void printWarning(String msg) {
    print(msg);
  }
}
