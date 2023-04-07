import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncovered_file_lines.dart';
import 'package:test/test.dart';

void main() {
  group("When GetUncoveredFileLines is called", () {
    test("should return the lines that are not covered by the lcov file", () {
      final useCase = GetUncoveredFileLines();
      final result = useCase(_content1.split("\n"), "lib/extensions/iterable.dart");

      expect(result!.length, 2);
      expect(result.first, 4);
      expect(result.last, 6);
    });

    test("should return the lines that are not covered by the lcov file if it uses absolute paths", () {
      final useCase = GetUncoveredFileLines();
      final result = useCase(_content2.split("\n"), "lib/src/extensions/string.dart");

      expect(result!.length, 4);
      expect(result.first, 13);
      expect(result.last, 18);
    });
  });
}

const _content1 = r'''DA:22,2
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

const _content2 = '''
SF:/Users/barreto/Projects/pull_request_coverage/lib/src/extensions/string.dart
DA:4,1
DA:5,1
DA:6,1
DA:13,0
DA:15,0
DA:16,0
DA:18,0
LF:7
LH:3
end_of_record
''';
