import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';

class IsAnIgnoredFile {
  final UserSettings userOptions;

  const IsAnIgnoredFile(this.userOptions);

  bool call(String filePath) {
    return userOptions.ignoredFiles.any((glob) => glob.matches(filePath));
  }
}
