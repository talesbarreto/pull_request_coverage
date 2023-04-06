import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

class IsAnIgnoredFile {
  final UserOptions userOptions;

  const IsAnIgnoredFile(this.userOptions);

  bool call(String filePath) {
    return userOptions.ignoredFiles.any((glob) => glob.matches(filePath));
  }
}
