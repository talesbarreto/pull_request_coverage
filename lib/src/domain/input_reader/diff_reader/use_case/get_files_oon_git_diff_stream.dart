import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';
import 'package:pull_request_coverage/src/presentation/logger/logger.dart';

/// Split the diff into file chunks and emits all lines of each of them
class GetFilesOnGitDiffStream {
  final Stream<String> diffLinesStream;

  const GetFilesOnGitDiffStream(this.diffLinesStream);

  Stream<List<String>> call() async* {
    List<String> fileContent = [];
    try {
      await for (final line in diffLinesStream) {
        if (line.startsWith("diff --git")) {
          if (fileContent.isNotEmpty) {
            yield fileContent;
          }
          fileContent = [line];
        } else {
          fileContent.add(line);
          fileContent;
        }
      }
      if (fileContent.isNotEmpty) {
        yield fileContent;
      }
    } catch (e, s) {
      logger.log(
        message: e.toString(),
        stackTrace: s,
        tag: 'OnFilesOnGitDiff',
        level: LogLevel.error,
      );
      print(e);
    }
    return;
  }
}
