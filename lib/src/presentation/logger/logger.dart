import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

class Logger {
  static Logger _global = Logger();

  static Logger get global => _global;

  static void setGlobalLogger(Logger logger) => _global = logger;

  final LogLevel logLevel;

  const Logger({this.logLevel = LogLevel.none});

  void printError({
    required String origin,
    required String msg,
    StackTrace? stackTrace,
  }) {
    print("[ERROR] $origin: $msg \n $stackTrace");
  }

  void printWarning({
    required String origin,
    required String msg,
  }) {
    print("[WARNING] $origin: $msg");
  }

  void printInfo({
    required String origin,
    required String msg,
  }) {
    print("[INFO] $origin: $msg");
  }

  void printVerbose({
    required String origin,
    required String msg,
  }) {
    print("$origin: $msg");
  }
}
