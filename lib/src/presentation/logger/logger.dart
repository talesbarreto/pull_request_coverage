import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';

class Logger {
  final ColorizeText colorizeCliText;
  static Logger? _global;

  static Logger? get global => _global;

  static void setGlobalLogger(Logger logger) => _global = logger;

  final LogLevel logLevel;

  Logger({
    this.logLevel = LogLevel.none,
    required this.colorizeCliText,
  });

  void printError({
    required String msg,
    String? origin,
    StackTrace? stackTrace,
    bool alwaysPrint = false,
  }) {
    if (alwaysPrint || logLevel.index >= LogLevel.error.index) {
      print("${colorizeCliText("[ERROR] ${origin != null ? "$origin: " : ""}$msg", TextColor.red)}\n $stackTrace");
    }
  }

  void printWarning({
    required String msg,
    String? origin,
  }) {
    if (logLevel.index >= LogLevel.warning.index) {
      print(colorizeCliText("[WARNING] ${origin != null ? "$origin: " : ""}$msg", TextColor.yellow));
    }
  }

  void printInfo({
    required String msg,
    String? origin,
    bool alwaysPrint = false,
  }) {
    if (alwaysPrint || logLevel.index >= LogLevel.info.index) {
      print(colorizeCliText("${origin != null ? "$origin: " : ""}$msg", TextColor.cyan));
    }
  }

  void printVerbose({
    required String msg,
    String? origin,
  }) {
    if (logLevel.index >= LogLevel.info.index) {
      print(colorizeCliText("${origin != null ? "$origin: " : ""}$msg", TextColor.white));
    }
  }
}
