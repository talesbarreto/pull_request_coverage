/// Split the diff into files chunks and call the callback for each one of them
class OnFilesOnGitDiff {
  final Stream<String> diffLinesStream;

  const OnFilesOnGitDiff(this.diffLinesStream);

  Stream<List<String>> call() async* {
    List<String> fileContent = [];
    await for (final line in diffLinesStream) {
      if (line.startsWith("diff --git")) {
        if (fileContent.isNotEmpty) {
          yield fileContent;
        }
        fileContent = [line];
      } else {
        fileContent.add(line);
        fileContent;
      }
    }
    if (fileContent.isNotEmpty) {
      yield fileContent;
    }
    return;
  }
}
