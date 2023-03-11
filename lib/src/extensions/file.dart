import 'dart:io';

extension FileExtention on FileSystemEntity {
  String get name {
    return path.split(Platform.pathSeparator).last;
  }
}
