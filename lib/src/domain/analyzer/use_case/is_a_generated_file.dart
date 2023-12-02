import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';

class IsAGeneratedFile {
  final UserSettings userOptions;

  const IsAGeneratedFile(this.userOptions);

  bool call(String filePath) {
    return userOptions.knownGeneratedFiles.any((glob) => glob.matches(filePath));
  }
}
