import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class Logger {
  final ColorizeCliText colorizeCliText;
  static Logger? _global;

  static Logger? get global => _global;

  static void setGlobalLogger(Logger logger) => _global = logger;

  final LogLevel logLevel;

  Logger({
    this.logLevel = LogLevel.none,
    required this.colorizeCliText,
  });

  void printError({
    required String origin,
    required String msg,
    StackTrace? stackTrace,
    bool alwaysPrint = false,
  }) {
    if (alwaysPrint || logLevel.index >= LogLevel.error.index) {
      print("${colorizeCliText("[ERROR] $origin: $msg", TextColor.red)}\n $stackTrace");
    }
  }

  void printWarning({
    required String origin,
    required String msg,
  }) {
    if (logLevel.index >= LogLevel.warning.index) {
      print(colorizeCliText("[WARNING] $origin: $msg", TextColor.yellow));
    }
  }

  void printInfo({
    required String origin,
    required String msg,
    bool alwaysPrint = false,
  }) {
    if (alwaysPrint || logLevel.index >= LogLevel.info.index) {
      print(colorizeCliText("$origin: $msg", TextColor.cyan));
    }
  }

  void printVerbose({
    required String origin,
    required String msg,
  }) {
    if (logLevel.index >= LogLevel.info.index) {
      print(colorizeCliText("$origin: $msg", TextColor.white));
    }
  }
}
