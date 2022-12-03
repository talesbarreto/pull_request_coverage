import 'dart:io';

class ReadLcovFile {
  Future<List<String>> call(String lcovFilePath) async {
    final file = File(lcovFilePath);
    if (!await file.exists()) {
      throw Exception("File not found: $lcovFilePath");
    }
    return file.readAsLines();
  }
}
