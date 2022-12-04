import 'package:pull_request_coverage/domain/user_options/models/user_options.dart';

class ShouldAnalyseThisFile {
  final UserOptions userOptions;

  ShouldAnalyseThisFile(this.userOptions);

  bool call(String filePath) {
    return filePath.endsWith(".dart") && filePath.startsWith("lib/") && !userOptions.excludePrefixPaths.any(filePath.startsWith) && !userOptions.excludeSuffixPaths.any(filePath.endsWith);
  }
}
