import 'dart:io';

// This is why: https://github.com/flutter/flutter/issues/27997#issuecomment-1144247839

const packageName = 'pull_request_coverage';

void main() async {
  final cwd = Directory.current.uri;
  final libDir = Directory.fromUri(cwd.resolve('lib'));
  final buffer = StringBuffer();

  var files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) =>
          file.path.endsWith('.dart') &&
          !file.path.contains('.freezed.') &&
          !file.path.contains('.g.') &&
          !file.path.endsWith('generated_plugin_registrant.dart'))
      .toList();

  buffer.writeln('// ignore_for_file: unused_import');
  buffer.writeln();

  for (var file in files) {
    final fileLibPath =
        file.uri.toFilePath().substring(libDir.uri.toFilePath().length);
    buffer.writeln('import \'package:$packageName/$fileLibPath\';');
  }

  buffer.writeln();
  buffer.writeln('void main() {}');

  final output =
      File(cwd.resolve('test/coverage_helper_test.dart').toFilePath());
  await output.writeAsString(buffer.toString());
}
