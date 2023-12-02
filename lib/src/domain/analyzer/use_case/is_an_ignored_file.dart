import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';

class IsAnIgnoredFile {
  final UserSettings userSettings;

  const IsAnIgnoredFile(this.userSettings);

  bool call(String filePath) {
    return userSettings.ignoredFiles.any((glob) => glob.matches(filePath));
  }
}
