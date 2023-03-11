abstract class IoRepository {
  /// Reads a single line from [stdin] asynchronously.
  Future<String?> readStdinLine();

  Future<String?> getGitRootRelativePath();
}
