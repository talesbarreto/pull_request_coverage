import 'dart:async';
import 'dart:io';
import 'package:file/file.dart';
import 'package:pull_request_coverage/src/domain/file/repository/file_repository.dart';

import 'package:pull_request_coverage/src/extensions/file.dart';

class FileRepositoryImpl implements FileRepository {
  static const gitFileName = ".git";

  final FileSystem fileSystem;
  final Duration stdinTimeout;

  const FileRepositoryImpl({
    required this.fileSystem,
    required this.stdinTimeout,
  });

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
