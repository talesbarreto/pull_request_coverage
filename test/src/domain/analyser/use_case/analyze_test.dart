import 'package:mocktail/mocktail.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_file_from_project.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
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

  test('do not analyze file if `IsAFileFromProject` returns false', () {
    final getUncoveredFileLines = _MockGetUncoveredFileLines();
    final analyze = _getAnalyze(isAFileFromProject: _FakeIsAFileFromProject(response: false));

    analyze();

    verifyNever(() => getUncoveredFileLines.call(any(), any()));
  });

  group('When there is three files, each one has two new lines and one of them is uncovered', () {
    const totalOfFilesOnDiff = 3;
    // To simplify the test, all files are equal
    final linesOfEachFile = [
      FileLine(line: "int main(){", lineNumber: 1, isANewLine: true, isUncovered: true, ignored: false),
      FileLine(line: "   print(\"oba\")", lineNumber: 2, isANewLine: true, isUncovered: false, ignored: false),
      FileLine(line: "   return 0", lineNumber: 3, isANewLine: false, isUncovered: true, ignored: false),
    ];

    final setUncoveredLines = _MockSetUncoveredLinesOnFileDiff();

    final analyze = _getAnalyze(
      mockParseGitHubDiff: _MockParseGitHubDiff(
        answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
      ),
      mockForEachFileOnGitDiff:
          _MockForEachFileOnGitDiff.dummy(List.generate(totalOfFilesOnDiff, (index) => ["file$index"])),
      mockGetUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 3]),
      mockSetUncoveredLinesOnFileDiff: setUncoveredLines,
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

  test(
    "ignored lines should count for totalOfIgnoredLinesMissingTests but not for totalOfNewLines nor totalOfUncoveredNewLines",
    () async {
      final linesOfEachFile = [
        FileLine(line: "int main(){", lineNumber: 1, isANewLine: true, isUncovered: true, ignored: true),
        FileLine(line: "   print(\"oba\")", lineNumber: 2, isANewLine: true, isUncovered: false, ignored: true),
        FileLine(line: "   return 0", lineNumber: 3, isANewLine: true, isUncovered: true, ignored: true),
        FileLine(line: "   return 0", lineNumber: 4, isANewLine: true, isUncovered: true, ignored: false),
      ];
      final analyze = _getAnalyze(
        mockParseGitHubDiff: _MockParseGitHubDiff(
          answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
        ),
        mockGetUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 2, 3, 4]),
      );
      final analyzeResult = await analyze();
      expect(analyzeResult.totalOfNewLines, 1);
      expect(analyzeResult.totalOfIgnoredLinesMissingTests, 2);
      expect(analyzeResult.totalOfUncoveredNewLines, 1);
    },
  );
}

Analyze _getAnalyze({
  _MockParseGitHubDiff? mockParseGitHubDiff,
  _FakeIsAFileFromProject? isAFileFromProject,
  _MockGetUncoveredFileLines? mockGetUncoveredFileLines,
  _MockForEachFileOnGitDiff? mockForEachFileOnGitDiff,
  _MockSetUncoveredLinesOnFileDiff? mockSetUncoveredLinesOnFileDiff,
}) {
  return Analyze(
    parseGitDiff: mockParseGitHubDiff ?? _MockParseGitHubDiff(),
    forEachFileOnGitDiff: mockForEachFileOnGitDiff ??
        _MockForEachFileOnGitDiff.dummy([
          ["aho"]
        ]),
    lcovLines: [],
    shouldAnalyzeThisFile: _MockShouldAnalyzeThisFile.dummy(true),
    setUncoveredLines: mockSetUncoveredLinesOnFileDiff ?? _MockSetUncoveredLinesOnFileDiff(),
    getUncoveredFileLines: mockGetUncoveredFileLines ?? _MockGetUncoveredFileLines(),
    printResultForFile: _MockPrintResultForFile(),
    isAFileFromProject: isAFileFromProject ?? _FakeIsAFileFromProject(),
  );
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

class _MockShouldAnalyzeThisFile extends Mock implements ShouldAnalyzeThisFile {
  _MockShouldAnalyzeThisFile();

  factory _MockShouldAnalyzeThisFile.dummy(bool answer) {
    final mock = _MockShouldAnalyzeThisFile();
    when(() => mock.call(any())).thenReturn(answer);
    return mock;
  }
}

class _MockSetUncoveredLinesOnFileDiff extends Mock implements SetFileLineResultData {}

class _MockGetUncoveredFileLines extends Mock implements GetUncoveredFileLines {
  _MockGetUncoveredFileLines();

  factory _MockGetUncoveredFileLines.dummy(List<int>? answer) {
    final mock = _MockGetUncoveredFileLines();
    when(() => mock.call(any(), any())).thenReturn(answer);
    return mock;
  }
}

class _MockPrintResultForFile extends Mock implements PrintResultForFile {}

class _FakeIsAFileFromProject extends Fake implements IsAFileFromProject {
  final bool response;

  _FakeIsAFileFromProject({this.response = true});

  @override
  bool call(String path) => response;
}
