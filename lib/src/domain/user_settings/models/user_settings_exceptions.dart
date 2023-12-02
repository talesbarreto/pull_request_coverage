abstract class UserSettingsException implements Exception {
  String get settingName;

  @override
  String toString();
}

class InvalidUserSettingsException implements UserSettingsException {
  @override
  final String settingName;
  final String source;

  const InvalidUserSettingsException(this.settingName, this.source);

  @override
  String toString() => "Invalid setting `$settingName` on $source settings";
}

class InvalidUserSettingsArg implements UserSettingsException {
  @override
  final String settingName;
  final String source;

  const InvalidUserSettingsArg(this.settingName, this.source);

  @override
  String toString() => "User setting `$settingName`, on $source settings, requires an argument";
}
