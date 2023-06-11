import 'package:pull_request_coverage/src/presentation/logger/logger.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_text.dart';

class PrintWarningsForUnexpectedFileStructure {
  final void Function(String message) print;
  final ColorizeText colorizeText;
  final Logger logger;

  const PrintWarningsForUnexpectedFileStructure(this.print, this.colorizeText, this.logger);

  void call({
    required String? gitRootRelativePath,
    required bool isLibDirPresent,
  }) {
    if (gitRootRelativePath == null) {
      logger.printWarning(msg: "no `.git` file was found on current directory nor any of its ancestors");
    }
    if (!isLibDirPresent) {
      logger.printWarning(msg: "`./lib` is expected but was not found");
    }
  }
}
