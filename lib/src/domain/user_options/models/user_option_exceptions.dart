abstract class UserOptionException implements Exception {
  String get optionName;

  @override
  String toString();
}

class InvalidUserOptionException implements UserOptionException {
  @override
  final String optionName;
  final String source;

  const InvalidUserOptionException(this.optionName, this.source);

  @override
  String toString() => "Invalid option `$optionName` on $source options";
}

class InvalidUserOptionsArg implements UserOptionException {
  @override
  final String optionName;
  final String source;

  const InvalidUserOptionsArg(this.optionName, this.source);

  @override
  String toString() => "User option `$optionName`, on $source options, requires an argument";
}
