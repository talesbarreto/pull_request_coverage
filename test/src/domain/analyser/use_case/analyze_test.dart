import 'package:mocktail/mocktail.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/get_file_report_from_diff.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_generated_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_an_ignored_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncovered_file_lines.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FileDiff(path: '', lines: []));
  });

  test('Exclude file file from the report if `GetUncoveredFileLines` returns null', () async {
    final getUncoveredFileLines = _MockGetUncoveredFileLines();
    final analyze = _getAnalyze(getUncoveredFileLines: getUncoveredFileLines);

    when(() => getUncoveredFileLines.call(any(), any())).thenReturn(null);

    final result = await analyze().toList();

    expect(result.length, 1);
    expect(result.first.analysisResult, isNotNull);
  });

  group('When there is three files, each one has two new lines and one of them is uncovered', () {
    const totalOfFilesOnDiff = 3;
    Future<AnalysisResult> getAnalysisResult(
        [_MockSetUncoveredLinesOnFileDiff? mockSetUncoveredLinesOnFileDiff]) async {
      // To simplify the test, all files are equal
      final linesOfEachFile = [
        FileLine(code: "int main(){", lineNumber: 1, isNew: true, isUntested: true, ignored: false),
        FileLine(code: "   print(\"oba\")", lineNumber: 2, isNew: true, isUntested: false, ignored: false),
        FileLine(code: "   return 0", lineNumber: 3, isNew: false, isUntested: true, ignored: false),
      ];

      final setUncoveredLines = mockSetUncoveredLinesOnFileDiff ?? _MockSetUncoveredLinesOnFileDiff();

      final analyze = _getAnalyze(
        parseGitHubDiff: _MockParseGitHubDiff(
          answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
        ),
        filesOnGitDIffStream: Stream.fromIterable(List.generate(totalOfFilesOnDiff, (index) => ["file$index"])),
        getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 3]),
        setUncoveredLinesOnFileDiff: setUncoveredLines,
      );

      return (await analyze().last).analysisResult!;
    }

    test('Expect $totalOfFilesOnDiff uncovered lines reported by `analyze', () async {
      expect((await getAnalysisResult()).linesMissingTests, totalOfFilesOnDiff);
    });
    test('Expect $totalOfFilesOnDiff new lines reported by `analyze`', () async {
      expect((await getAnalysisResult()).linesThatShouldBeTested, 2 * totalOfFilesOnDiff);
    });
    test('expect to invoke `setUncoveredLines` for each file', () async {
      final setUncoveredLines = _MockSetUncoveredLinesOnFileDiff();
      await getAnalysisResult(setUncoveredLines);
      verify(() => setUncoveredLines.call(any(), any())).called(totalOfFilesOnDiff);
    });
  });

  test("generated files should not count on results", () async {
    final linesOfEachFile = [
      FileLine(code: "int main(){", lineNumber: 1, isNew: true, isUntested: true, ignored: false),
    ];
    final analyze = _getAnalyze(
      parseGitHubDiff: _MockParseGitHubDiff(
        answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
      ),
      getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 2, 3, 4]),
      isAGeneratedFile: _MockIsAGeneratedFile.dummy(true),
    );
    final analyzeResult = (await analyze().last).analysisResult!;
    expect(analyzeResult.linesThatShouldBeTested, 0);
    expect(analyzeResult.untestedIgnoredLines, 0);
    expect(analyzeResult.linesMissingTests, 0);
  });

  test("ignored files should count for total of `untested lines that were ignored`", () async {
    final linesOfEachFile = [
      FileLine(code: "int main(){", lineNumber: 1, isNew: true, isUntested: true, ignored: false),
    ];
    final analyze = _getAnalyze(
      parseGitHubDiff: _MockParseGitHubDiff(
        answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
      ),
      getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 2, 3, 4]),
      isAnIgnoredFile: _MockIsAnIgnoredFile.dummy(true),
    );
    final analyzeResult = (await analyze().last).analysisResult!;
    expect(analyzeResult.linesThatShouldBeTested, 0);
    expect(analyzeResult.untestedIgnoredLines, 1);
    expect(analyzeResult.linesMissingTests, 0);
  });

  test(
    "ignored lines should count for totalOfIgnoredLinesMissingTests but not for totalOfNewLines nor totalOfUncoveredNewLines",
    () async {
      final linesOfEachFile = [
        FileLine(code: "int main(){", lineNumber: 1, isNew: true, isUntested: true, ignored: true),
        FileLine(code: "   print(\"oba\")", lineNumber: 2, isNew: true, isUntested: false, ignored: true),
        FileLine(code: "   return 0", lineNumber: 3, isNew: true, isUntested: true, ignored: true),
        FileLine(code: "   return 0", lineNumber: 4, isNew: true, isUntested: true, ignored: false),
      ];
      final analyze = _getAnalyze(
        parseGitHubDiff: _MockParseGitHubDiff(
          answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
        ),
        getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 2, 3, 4]),
      );
      final analyzeResult = (await analyze().last).analysisResult!;
      expect(analyzeResult.linesThatShouldBeTested, 1);
      expect(analyzeResult.untestedIgnoredLines, 2);
      expect(analyzeResult.linesMissingTests, 1);
    },
  );
}

Analyze _getAnalyze({
  _MockParseGitHubDiff? parseGitHubDiff,
  _MockGetUncoveredFileLines? getUncoveredFileLines,
  Stream<List<String>>? filesOnGitDIffStream,
  _MockSetUncoveredLinesOnFileDiff? setUncoveredLinesOnFileDiff,
  _MockIsAGeneratedFile? isAGeneratedFile,
  _MockIsAnIgnoredFile? isAnIgnoredFile,
}) {
  return Analyze(
    parseGitDiff: parseGitHubDiff ?? _MockParseGitHubDiff(),
    filesOnGitDIffStream: filesOnGitDIffStream ??
        Stream.fromIterable([
          ["aho"]
        ]),
    lcovLines: [],
    setUncoveredLines: setUncoveredLinesOnFileDiff ?? _MockSetUncoveredLinesOnFileDiff(),
    getUncoveredFileLines: getUncoveredFileLines ?? _MockGetUncoveredFileLines(),
    isAGeneratedFile: isAGeneratedFile ?? _MockIsAGeneratedFile.dummy(false),
    isAnIgnoredFile: isAnIgnoredFile ?? _MockIsAnIgnoredFile.dummy(false),
    getFileReportFromDiff: GetFileReportFromDiff(),
    userOptions: const UserSettings(),
  );
}

class _MockParseGitHubDiff extends Mock implements ParseGitDiff {
  final FileDiff? answer;

  _MockParseGitHubDiff({this.answer = const FileDiff(path: '/var/tmp/ha.dart', lines: [])});

  @override
  FileDiff? call(List<String> fileLines) => answer;
}

class _MockIsAGeneratedFile extends Mock implements IsAGeneratedFile {
  _MockIsAGeneratedFile();

  factory _MockIsAGeneratedFile.dummy(bool answer) {
    final mock = _MockIsAGeneratedFile();
    when(() => mock.call(any())).thenReturn(answer);
    return mock;
  }
}

class _MockIsAnIgnoredFile extends Mock implements IsAnIgnoredFile {
  _MockIsAnIgnoredFile();

  factory _MockIsAnIgnoredFile.dummy(bool answer) {
    final mock = _MockIsAnIgnoredFile();
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
