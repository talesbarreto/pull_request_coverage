import 'package:pull_request_coverage/src/extensions/string.dart';

// fixing this issue [https://github.com/talesbarreto/pull_request_coverage/issues/3]
// where pull_request_coverage was not working when `.git` file and `/lib` directory ware not in the same directory

// [RemoveGitRootRelativePath] will be used during diff parse, replacing path read from diff by [call]
// making it match with those read from `lcov.info`
class RemoveGitRootRelativePath {
  final String? gitRootRelativePath;

  const RemoveGitRootRelativePath(this.gitRootRelativePath);

  String call(String path) {
    final gitRootRelativePath = this.gitRootRelativePath;
    if (gitRootRelativePath == null || gitRootRelativePath.isEmpty) {
      // preserving version `1.0.3` behavior: if `.git` file was not found: keep going 🎠, hopping that it will work
      return path;
    }
    return path.removePrefix(gitRootRelativePath);
  }
}
