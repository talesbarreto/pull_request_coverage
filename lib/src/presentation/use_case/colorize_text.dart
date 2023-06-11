class ColorizeText {
  static const ignoredUntestedCodeColor = TextColor.cyan;

  final bool useColorfulOutput;

  const ColorizeText({
    required this.useColorfulOutput,
  });

  String call(String text, TextColor color) {
    if (useColorfulOutput) {
      return "${color.colorCode}$text${TextColor.noColor.colorCode}";
    } else {
      return text;
    }
  }
}

enum TextColor {
  black("\x1B[30m"),
  red("\x1B[31m"),
  green("\x1B[32m"),
  yellow("\x1B[33m"),
  blue("\x1B[34m"),
  magenta("\x1B[35m"),
  cyan("\x1B[36m"),
  white("\x1B[37m"),
  noColor("\x1B[0m");

  final String colorCode;

  const TextColor(this.colorCode);
}
