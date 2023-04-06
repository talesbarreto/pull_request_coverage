import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

class IsAGeneratedFile {
  final UserOptions userOptions;

  const IsAGeneratedFile(this.userOptions);

  bool call(String filePath) {
    return userOptions.knownGeneratedFiles.any((glob) => glob.matches(filePath));
  }
}
