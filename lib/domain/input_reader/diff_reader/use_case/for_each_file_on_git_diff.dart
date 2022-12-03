class ForEachFileOnGitDiff {
  final String? Function() readLine;

  const ForEachFileOnGitDiff(this.readLine);

  void call(void Function(List<String> lines) onFile) {
    final firstLine = readLine();
    if (firstLine == null) {
      return;
    }
    List<String> fileContent = [firstLine];
    do {
      final newLine = readLine();
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
