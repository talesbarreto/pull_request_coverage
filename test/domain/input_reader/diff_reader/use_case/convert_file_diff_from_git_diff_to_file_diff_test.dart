  String defaultPathTransformer(String path) => path;
    final useCase = ParseGitDiff(defaultPathTransformer);
      () => expect(
          result.lines.firstWhere((element) => element.lineNumber == 55).line, "    image: cirrusci/flutter:3.3.7"),
    final useCase = ParseGitDiff(defaultPathTransformer);
      () => expect(result.lines.firstWhere((element) => element.lineNumber == 2).line,
          "import 'package:flutter_svg/flutter_svg.dart';"),
const _file2Content =
    r'''diff --git a/lib/presentation/widgets/download_all_modal.dart b/lib/presentation/widgets/download_all_modal.dart