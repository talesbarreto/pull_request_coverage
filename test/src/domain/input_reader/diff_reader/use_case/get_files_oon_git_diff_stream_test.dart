import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/get_files_oon_git_diff_stream.dart';
import 'package:test/test.dart';

void main() {
  const fileContent = [
    "diff --git",
    "a",
    "@override",
    " Widget build(BuildContext context) {",
    " return ;",
    "}",
    "diff --git ha",
    ".",
    "diff --git he",
    "u",
    "a",
  ];

  group("split the input on each line started by `diff --git`", () {
    Future<List<List<String>>> getTestFiles() async {
      final useCase = GetFilesOnGitDiffStream(Stream.fromIterable(fileContent));
      return useCase().toList();
    }

    test("should return 3 files", () async {
      expect((await getTestFiles()).length, 3);
    });

    test("content of the first file must be right", () async {
      final file = (await getTestFiles())[0];
      expect(file[0], "diff --git");
      expect(file[1], "a");
      expect(file[2], "@override");
      expect(file[3], " Widget build(BuildContext context) {");
      expect(file[4], " return ;");
      expect(file[5], "}");
    });

    test("content of the second file must be right", () async {
      final file = (await getTestFiles())[1];
      expect(file[0], "diff --git ha");
      expect(file[1], ".");
    });

    test("content of the third file must be right", () async {
      final file = (await getTestFiles())[2];
      expect(file[0], "diff --git he");
      expect(file[1], "u");
      expect(file[2], "a");
    });
  });
}
