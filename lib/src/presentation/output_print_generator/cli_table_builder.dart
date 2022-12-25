import 'package:pull_request_coverage/src/extensions/string.dart';

class CliTableBuilder {
  static const headerDivider = "-";
  static const columnDivider = "|";

  final int columnsLength;
  final List<String>? header;

  CliTableBuilder({required this.columnsLength, this.header});

  final List<List<String>> table = [];

  void addLine(List<String> columns) {
    if (columns.length != columnsLength) {
      throw Exception("line length is not equal to the declared one");
    }
    table.add(columns);
  }

  String _createContent(String content, int minLength, String filler) {
    final remaining = content.length > minLength ? 0 : minLength - content.length;
    final suffix = remaining % 2 == 0 ? "" : filler;
    return "$filler${filler * (remaining ~/ 2)}$content${filler * (remaining ~/ 2)}$suffix$filler";
  }

  String build() {
    final stringBuffer = StringBuffer();
    final columnSize = List.generate(columnsLength, (index) => 0);
    for (var columnIndex = 0; columnIndex < columnsLength; columnIndex++) {
      for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {
        if (table[lineIndex][columnIndex].getLengthWithNoColor() > columnSize[columnIndex]) {
          columnSize[columnIndex] = table[lineIndex][columnIndex].getLengthWithNoColor();
        }
      }
    }
    final header = this.header;
    if (header != null) {
      for (var i = 0; i < header.length; i++) {
        if (header[i].length > columnSize[i]) {
          columnSize[i] = header[i].length;
        }
        stringBuffer.write(_createContent(header[i], columnSize[i], " "));
        if (i != header.length - 1) {
          stringBuffer.write(columnDivider);
        }
      }
      stringBuffer.writeln();
      for (var i = 0; i < header.length; i++) {
        stringBuffer.write(_createContent("", columnSize[i], "-"));
        if (i != header.length - 1) {
          stringBuffer.write(columnDivider);
        }
      }
    }
    for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {
      stringBuffer.writeln();
      for (var columnIndex = 0; columnIndex < columnsLength; columnIndex++) {
        stringBuffer.write(_createContent(table[lineIndex][columnIndex], columnSize[columnIndex], " "));
        if (columnIndex < columnsLength - 1) {
          stringBuffer.write(columnDivider);
        }
      }
    }
    return stringBuffer.toString();
  }
}
