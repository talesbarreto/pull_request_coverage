import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

class ShouldAnalyzeThisFile {
  final UserOptions userOptions;

  const ShouldAnalyzeThisFile(this.userOptions);

  bool call(String filePath) {
    return filePath.endsWith(".dart") &&
        filePath.startsWith("lib/") &&
        !userOptions.excludeFile.any((glob) => glob.matches(filePath));
  }
}
