import 'dart:async';
import 'dart:io';
import 'package:file/file.dart';

import 'package:pull_request_coverage/src/domain/io/repository/io_repository.dart';
import 'package:pull_request_coverage/src/extensions/file.dart';

class IoRepositoryImpl implements IoRepository {
  static const gitFileName = ".git";

  final Stream<String> stdinStream;

  final FileSystem fileSystem;
  final Duration stdinTimeout;

  const IoRepositoryImpl({
    required this.fileSystem,
    required this.stdinStream,
    required this.stdinTimeout,
  });

  @override
  Future<String?> readStdinLine() async {
    try {
      final line = await stdinStream.first.timeout(stdinTimeout);
      return line;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getGitRootRelativePath() async {
    Directory currentDirectory = fileSystem.currentDirectory;
    String relativePath = "";
    do {
      final children = await currentDirectory.list().toList();
      for (final child in children) {
        if (child.path.endsWith("${Platform.pathSeparator}$gitFileName") || child.path == gitFileName) {
          return relativePath;
        }
      }
      relativePath = "${currentDirectory.name}${Platform.pathSeparator}$relativePath";
      currentDirectory = currentDirectory.parent;
    } while (currentDirectory.path != currentDirectory.parent.path);
    return null;
  }

  @override
  Future<bool> doesLibDirectoryExist() async {
    for (final child in await fileSystem.currentDirectory.list().toList()) {
      if (child is Directory && child.name == "lib") {
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<String>> getLcovLines(String filePath, FileSystem fileSystem) {
    return fileSystem.file(filePath).readAsLines();
  }
}
