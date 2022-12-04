/// Split the diff into files chunks and call the callback for each one of them
class ForEachFileOnGitDiff {
  final Future<String?> Function() readLine;

  const ForEachFileOnGitDiff(this.readLine);

  Future<void> call(void Function(List<String> lines) onFile) async {
    final firstLine = await readLine();
    if (firstLine == null) {
      return;
    }
    List<String> fileContent = [firstLine];
    do {
      final newLine = await readLine();
      if (newLine == null) {
        if (fileContent.isNotEmpty) {
          onFile(fileContent);
        }
        return;
      }
      if (newLine.startsWith("diff --git")) {
        onFile(fileContent);
        fileContent = [newLine];
      } else {
        fileContent.add(newLine);
        fileContent;
      }
    } while (true);
  }
}
