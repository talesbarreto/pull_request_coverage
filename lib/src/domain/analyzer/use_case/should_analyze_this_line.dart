class ShouldAnalyzeThisLine {
  final List<RegExp> filters;

  const ShouldAnalyzeThisLine(this.filters);
  bool call(String line) {
    for (final regExp in filters) {
      if (regExp.stringMatch(line) == line) {
        return false;
      }
    }
    return true;
  }
}
