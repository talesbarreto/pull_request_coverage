import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';

class IsAGeneratedFile {
  final UserSettings userSettings;

  const IsAGeneratedFile(this.userSettings);

  bool call(String filePath) {
    return userSettings.knownGeneratedFiles.any((glob) => glob.matches(filePath));
  }
}
