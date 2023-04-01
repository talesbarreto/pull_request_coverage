import 'package:mocktail/mocktail.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_uncoverd_lines_on_file_diff.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/should_analyze_this_file.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncoverd_file_lines.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_result_for_file.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FileDiff(path: '', lines: []));
  });

  test('do not analyse file if `shouldAnalyseThisFile` returns false', () {
    final getUncoveredFileLines = _MockGetUncoveredFileLines();
    final analyze = Analyze(
      parseGitDiff: _MockParseGitHubDiff(),
      forEachFileOnGitDiff: _MockForEachFileOnGitDiff.dummy([
        ["aho"]
      ]),
      lcovLines: [],
      shouldAnalyzeThisFile: _MockShouldAnalyseThisFile.dummy(false),
      setUncoveredLines: _MockSetUncoveredLinesOnFileDiff(),
      getUncoveredFileLines: getUncoveredFileLines,
      printResultForFile: _MockPrintResultForFile(),
    );

    analyze();

    verifyNever(() => getUncoveredFileLines.call(any(), any()));
  });

  group('When there is three files, each one has two new lines ans one of them is uncovered', () {
    const totalOfFilesOnDiff = 3;
    // To simplify the test, all files are equal
    final linesOfEachFile = [
      FileLine(line: "int main(){", lineNumber: 1, isANewLine: true, isUncovered: true),
      FileLine(line: "   print(\"oba\")", lineNumber: 2, isANewLine: true, isUncovered: false),
      FileLine(line: "   return 0", lineNumber: 3, isANewLine: false, isUncovered: true),
    ];

    final setUncoveredLines = _MockSetUncoveredLinesOnFileDiff();

    final analyze = Analyze(
      parseGitDiff: _MockParseGitHubDiff(
        answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
      ),
      forEachFileOnGitDiff:
          _MockForEachFileOnGitDiff.dummy(List.generate(totalOfFilesOnDiff, (index) => ["file$index"])),
      lcovLines: [],
      shouldAnalyzeThisFile: _MockShouldAnalyseThisFile.dummy(true),
      setUncoveredLines: setUncoveredLines,
      getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 3]),
      printResultForFile: _MockPrintResultForFile(),
    );

    final analysisResult = analyze();

    test('Expect $totalOfFilesOnDiff uncovered lines reported by `analyze', () async {
      expect((await analysisResult).totalOfUncoveredNewLines, totalOfFilesOnDiff);
    });
    test('Expect $totalOfFilesOnDiff new lines reported by `analyze`', () async {
      expect((await analysisResult).totalOfNewLines, 2 * totalOfFilesOnDiff);
    });
    test('expect to invoke `setUncoveredLines` for each file', () {
      verify(() => setUncoveredLines.call(any(), any())).called(totalOfFilesOnDiff);
    });
  });
}

class _MockParseGitHubDiff extends Mock implements ParseGitDiff {
  final FileDiff? answer;

  _MockParseGitHubDiff({this.answer = const FileDiff(path: '/var/tmp/ha.dart', lines: [])});

  @override
  FileDiff? call(List<String> fileLines) => answer;
}

class _MockForEachFileOnGitDiff extends Mock implements ForEachFileOnGitDiff {
  _MockForEachFileOnGitDiff();

  factory _MockForEachFileOnGitDiff.dummy(List<List<String>> files) {
    final mock = _MockForEachFileOnGitDiff();
    when(() => mock(captureAny())).thenAnswer((realInvocation) async {
      final onFile = realInvocation.positionalArguments.first as void Function(List<String> lines);
      for (final file in files) {
        onFile(file);
      }
    });
    return mock;
  }
}

class _MockShouldAnalyseThisFile extends Mock implements ShouldAnalyzeThisFile {
  _MockShouldAnalyseThisFile();

  factory _MockShouldAnalyseThisFile.dummy(bool answer) {
    final mock = _MockShouldAnalyseThisFile();
    when(() => mock.call(any())).thenReturn(answer);
    return mock;
  }
}

class _MockSetUncoveredLinesOnFileDiff extends Mock implements SetUncoveredLinesOnFileDiff {}

class _MockGetUncoveredFileLines extends Mock implements GetUncoveredFileLines {
  _MockGetUncoveredFileLines();

  factory _MockGetUncoveredFileLines.dummy(List<int>? answer) {
    final mock = _MockGetUncoveredFileLines();
    when(() => mock.call(any(), any())).thenReturn(answer);
    return mock;
  }
}

class _MockPrintResultForFile extends Mock implements PrintResultForFile {}
