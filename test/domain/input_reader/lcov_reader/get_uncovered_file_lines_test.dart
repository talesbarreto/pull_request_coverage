import 'package:pull_request_coverage/domain/input_reader/locv_reader/get_uncoverd_file_lines.dart';
import 'package:test/test.dart';

void main() {
  group("When GetUncoveredFileLines is called", () {
    test("should return the lines that are not covered by the lcov file", () {
      final useCase = GetUncoveredFileLines();
      final result = useCase(content.split("\n"), "lib/extensions/iterable.dart");

      expect(result!.length, 2);
      expect(result.first, 4);
      expect(result.last, 6);
    });
  });
}

const content = r'''DA:22,2
LF:2
LH:2
end_of_record
SF:lib/shared/file_size.dart
DA:8,335
DA:10,0
DA:12,0
DA:14,4
DA:16,8
DA:20,20
DA:21,24
LF:7
LH:5
end_of_record
SF:lib/extensions/iterable.dart
DA:4,0
DA:6,0
DA:9,6
DA:10,12
LF:4
LH:2
end_of_record''';
