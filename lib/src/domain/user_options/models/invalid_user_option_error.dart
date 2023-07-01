class InvalidUserOptionError implements Exception {
  final String optionName;
  final String source;

  const InvalidUserOptionError(this.optionName, this.source);

  @override
  String toString() => "Invalid option `$optionName` on $source options";
}
