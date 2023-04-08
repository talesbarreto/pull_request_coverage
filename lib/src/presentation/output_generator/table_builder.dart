import 'package:pull_request_coverage/src/extensions/string.dart';

class TableBuilder {
  List<String> _header = [];

  static const headerDivider = "-";
  static const columnDivider = "|";

  void setHeader(List<String> header) {
    _header = header;
  }

  int get columnsLength => _header.length;

  TableBuilder();

  final List<List<String>> table = [];

  void addLine(List<String> columns) {
    if (columns.length != columnsLength) {
      throw Exception("line length is not equal to the declared one");
    }
    table.add(columns);
  }

  String _createContent(String content, int minLength, String filler) {
    final remaining = content.getLengthWithNoColor() > minLength ? 0 : minLength - content.getLengthWithNoColor();
    final suffix = remaining % 2 == 0 ? "" : filler;
    return "$filler${filler * (remaining ~/ 2)}$content${filler * (remaining ~/ 2)}$suffix$filler";
  }

  String build(bool surroundedByDivider) {
    final stringBuffer = StringBuffer();
    final columnSize = List.generate(columnsLength, (index) => 0);

    void writeDividerOnBorder() {
      if (surroundedByDivider) stringBuffer.write(columnDivider);
    }

    for (var columnIndex = 0; columnIndex < columnsLength; columnIndex++) {
      for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {
        if (table[lineIndex][columnIndex].getLengthWithNoColor() > columnSize[columnIndex]) {
          columnSize[columnIndex] = table[lineIndex][columnIndex].getLengthWithNoColor();
        }
      }
    }
    writeDividerOnBorder();
    for (var i = 0; i < _header.length; i++) {
      if (_header[i].length > columnSize[i]) {
        columnSize[i] = _header[i].length;
      }
      stringBuffer.write(_createContent(_header[i], columnSize[i], " "));
      if (i != _header.length - 1) {
        stringBuffer.write(columnDivider);
      }
    }
    writeDividerOnBorder();
    stringBuffer.writeln();
    writeDividerOnBorder();
    for (var i = 0; i < _header.length; i++) {
      stringBuffer.write(_createContent("", columnSize[i], "-"));
      if (i != _header.length - 1) {
        stringBuffer.write(columnDivider);
      }
    }
    writeDividerOnBorder();

    for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {
      stringBuffer.writeln();
      writeDividerOnBorder();
      for (var columnIndex = 0; columnIndex < columnsLength; columnIndex++) {
        stringBuffer.write(_createContent(table[lineIndex][columnIndex], columnSize[columnIndex], " "));
        if (columnIndex < columnsLength - 1) {
          stringBuffer.write(columnDivider);
        }
      }
      writeDividerOnBorder();
    }
    return stringBuffer.toString();
  }
}
