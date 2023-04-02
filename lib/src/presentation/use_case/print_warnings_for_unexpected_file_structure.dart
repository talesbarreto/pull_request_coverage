import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class PrintWarningsForUnexpectedFileStructure {
  final void Function(String message) print;
  final ColorizeCliText colorizeText;

  const PrintWarningsForUnexpectedFileStructure(this.print, this.colorizeText);

  String _printWarning(String message) {
    return colorizeText("\t [WARNING] $message, pull_request_coverage may not work properly", TextColor.yellow);
  }

  void call({
    required String? gitRootRelativePath,
    required bool isLibDirPresent,
  }) {
    if (gitRootRelativePath == null) {
      print(_printWarning("no `.git` file was found on current directory nor any of its ancestors"));
    }
    if (!isLibDirPresent) {
      print(_printWarning("`./lib` is expected but was not found"));
    }
  }
}
