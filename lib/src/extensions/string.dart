import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

extension RemovePrefix on String {
  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return replaceFirst(prefix, "");
    }
    return this;
  }
}

extension LengthWithNoColor on String {
  int getLengthWithNoColor() {
    var string = this;
    for (final textColor in TextColor.values) {
      string = string.replaceAll(textColor.colorCode, "");
    }
    return string.length;
  }
}
