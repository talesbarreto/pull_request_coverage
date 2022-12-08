import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/convert_file_diff_from_git_diff_to_file_diff.dart';
  group("When file1 content is mapped", () {
    final fileLines = _file1Content.split("\n");

  // bugfix
  group("When file2 content is mapped", () {
    final fileLines = _file2Content.split("\n");
    final useCase = ConvertFileDiffFromGitDiffToFileDiff();

    final result = useCase(fileLines)!;

    test(
      "expect that line 17 is `     commands:`",
      () => expect(result.lines.firstWhere((element) => element.lineNumber == 2).line, "+import 'package:flutter_svg/flutter_svg.dart';"),
    );
  });
const _file1Content = r'''diff --git a/.drone.yml b/.drone.yml

const _file2Content = r'''diff --git a/lib/presentation/widgets/download_all_modal.dart b/lib/presentation/widgets/download_all_modal.dart
new file mode 100644
index 000000000..13ebb664b
--- /dev/null
+++ b/lib/presentation/widgets/download_all_modal.dart
@@ -0,0 +1,112 @@
+import 'package:flutter/material.dart';
+import 'package:flutter_svg/flutter_svg.dart';
+import 'package:palco/presentation/constants/app_images.dart';
+import 'package:rammstein/presentation/constants/app_svgs.dart';
+import 'package:rammstein/presentation/themes/rammstein_color_scheme.dart';
+import 'package:rammstein/presentation/themes/rammstein_text_theme.dart';
+import 'package:rammstein/shared/file_size.dart';
''';