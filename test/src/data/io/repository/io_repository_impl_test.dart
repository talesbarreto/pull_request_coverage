import 'package:file/memory.dart';
import 'package:pull_request_coverage/src/data/io/repository/io_repository_impl.dart';
import 'package:test/test.dart';

void main() {
  group("when `getGitRootRelativePath` is invoked", () {
    test("return an empty string if `.git` file is the current directory", () async {
      final fileSystem = MemoryFileSystem();
      await fileSystem.currentDirectory.childFile(IoRepositoryImpl.gitFileName).create();
      final repository = IoRepositoryImpl(fileSystem: fileSystem, stdinStream: Stream.empty(), stdinTimeout: Duration.zero);

      final result = await repository.getGitRootRelativePath();

      expect(result, "");
    });

    test("return null string if `.git` is not present in any parent directory", () async {
      final fileSystem = MemoryFileSystem();
      final repository = IoRepositoryImpl(fileSystem: fileSystem, stdinStream: Stream.empty(), stdinTimeout: Duration.zero);

      final result = await repository.getGitRootRelativePath();

      expect(result, null);
    });

    test("return relative path of `.git` file from current directory if it is present on one of parents", () async {
      const gitPath = "ha/he/root/${IoRepositoryImpl.gitFileName}";
      const projectPath = "ha/he/root/projects/project";
      final fileSystem = MemoryFileSystem();
      final repository = IoRepositoryImpl(fileSystem: fileSystem, stdinStream: Stream.empty(), stdinTimeout: Duration.zero);

      await fileSystem.currentDirectory.childFile(gitPath).create(recursive: true);
      await fileSystem.currentDirectory.childDirectory(projectPath).create(recursive: true);
      fileSystem.currentDirectory = projectPath;

      final result = await repository.getGitRootRelativePath();

      expect(result, "projects/project/");
    });
  });

  group("when `doesLibDirectoryExist` is invoked", () {
    test("return `true` if `/lib` is present in current directory", () async {
      final fileSystem = MemoryFileSystem();
      final repository = IoRepositoryImpl(fileSystem: fileSystem, stdinStream: Stream.empty(), stdinTimeout: Duration.zero);

      await fileSystem.currentDirectory.childDirectory("lib").create(recursive: true);

      expect(await repository.doesLibDirectoryExist(), isTrue);
    });
    test("return `false` if `/lib` is not present in current directory", () async {
      final fileSystem = MemoryFileSystem();
      final repository = IoRepositoryImpl(fileSystem: fileSystem, stdinStream: Stream.empty(), stdinTimeout: Duration.zero);

      expect(await repository.doesLibDirectoryExist(), isFalse);
    });
  });
}
