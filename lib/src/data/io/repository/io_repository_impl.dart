import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file/file.dart';

import 'package:pull_request_coverage/src/domain/io/repository/io_repository.dart';
import 'package:pull_request_coverage/src/extensions/file.dart';

class IoRepositoryImpl implements IoRepository {
  static const gitFileName = ".git";

  late final Stream<String> _stdinLineStreamBroadcaster = stdin.transform(utf8.decoder).transform(const LineSplitter()).asBroadcastStream();

  final FileSystem fileSystem;
  final Stdin stdin;

  IoRepositoryImpl(this.fileSystem, this.stdin);

  @override
  Future<String?> readStdinLine() async {
    try {
      final line = await _stdinLineStreamBroadcaster.first.timeout(Duration(seconds: 1));
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
}
