import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:test/test.dart';

void main() {
  const fileContent = r'''diff --git
a
@override 
 Widget build(BuildContext context) { 
 return ; 
}
diff --git ha
.
diff --git he
u
a''';

  group("split the input on each line started by `diff --git`", () {
    var currentLine = 0;
    final inputSplitByLines = fileContent.split("\n");
    final files = <List<String>>[];

    final useCase = ForEachFileOnGitDiff(() async {
      if (currentLine >= inputSplitByLines.length) {
        return null;
      }
      final line = inputSplitByLines[currentLine];
      currentLine++;
      return line;
    });

    useCase((file) {
      files.add(file);
    });

    test("should return 3 files", () {
      expect(files.length, 3);
    });

    test("content of the first file must be right", () {
      final file = files[0];
      expect(file[0], "diff --git");
      expect(file[1], "a");
      expect(file[2], "@override ");
      expect(file[3], " Widget build(BuildContext context) { ");
      expect(file[4], " return ; ");
      expect(file[5], "}");
    });

    test("content of the second file must be right", () {
      final file = files[1];
      expect(file[0], "diff --git ha");
      expect(file[1], ".");
    });

    test("content of the third file must be right", () {
      final file = files[2];
      expect(file[0], "diff --git he");
      expect(file[1], "u");
      expect(file[2], "a");
    });
  });
}
