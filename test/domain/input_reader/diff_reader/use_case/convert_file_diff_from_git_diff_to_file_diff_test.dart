import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:test/test.dart';

void main() {
  String defaultPathTransformer(String path) => path;
  group("When file1 content is mapped", () {
    final fileLines = _file1Content.split("\n");
    final useCase = ParseGitDiff(defaultPathTransformer);

    final result = useCase(fileLines)!;

    test("expect correct file name", () => expect(result.path, ".drone.yml"));
    test(
      "line 17 is `     commands:`",
      () => expect(result.lines.firstWhere((element) => element.lineNumber == 17).line, "     commands:"),
    );
    test(
      "line 55 is `    image: cirrusci/flutter:3.3.7`",
      () => expect(
          result.lines.firstWhere((element) => element.lineNumber == 55).line, "    image: cirrusci/flutter:3.3.7"),
    );
  });

  // bugfix
  group("When file2 content is mapped", () {
    final fileLines = _file2Content.split("\n");
    final useCase = ParseGitDiff(defaultPathTransformer);

    final result = useCase(fileLines)!;

    test(
      "expect that line 17 is `     commands:`",
      () => expect(result.lines.firstWhere((element) => element.lineNumber == 2).line,
          "import 'package:flutter_svg/flutter_svg.dart';"),
    );
  });
}

const _file1Content = r'''diff --git a/.drone.yml b/.drone.yml
index 170b94f65..74cb4811c 100644
--- a/.drone.yml
+++ b/.drone.yml
@@ -13,7 +13,7 @@ workspace:

 steps:
   - name: pub-get
-    image: cirrusci/flutter:3.3.8
+    image: cirrusci/flutter:3.3.7
     commands:
       - flutter pub get
       - flutter pub get plugins/cover_snitch
@@ -22,7 +22,7 @@ steps:
         path: /pub-cache

   - name: format
-    image: cirrusci/flutter:3.3.8
+    image: cirrusci/flutter:3.3.7
     commands:
       - flutter format --line-length=200 --set-exit-if-changed lib test
     depends_on:
@@ -32,7 +32,7 @@ steps:
         path: /pub-cache

   - name: analyze
-    image: cirrusci/flutter:3.3.8
+    image: cirrusci/flutter:3.3.7
     commands:
       - flutter analyze --no-pub .
     depends_on:
@@ -42,7 +42,7 @@ steps:
         path: /pub-cache

   - name: image-files-check
-    image: cirrusci/flutter:3.3.8
+    image: cirrusci/flutter:3.3.7
     commands:
       - flutter pub run images_files_checker --path assets/images --fail-test-on-unexpected-dir
     depends_on:
@@ -52,7 +52,7 @@ steps:
         path: /pub-cache

   - name: tests
-    image: cirrusci/flutter:3.3.8
+    image: cirrusci/flutter:3.3.7
     commands:
       - dart ci/generate_coverage_helper.dart
       - flutter test --no-pub --coverage -r expanded
''';

const _file2Content =
    r'''diff --git a/lib/presentation/widgets/download_all_modal.dart b/lib/presentation/widgets/download_all_modal.dart
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
