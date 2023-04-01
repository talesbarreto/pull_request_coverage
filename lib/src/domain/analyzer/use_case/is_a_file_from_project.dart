class IsAFileFromProject {
  bool call(String filePath) {
    return filePath.endsWith(".dart") && filePath.startsWith("lib/");
  }
}
