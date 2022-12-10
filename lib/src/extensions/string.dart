extension RemovePrefix on String {
  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return replaceFirst(prefix, "");
    }
    return this;
  }
}