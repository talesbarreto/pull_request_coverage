import 'package:mocktail/mocktail.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/analyze.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_file_from_project.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_a_generated_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/is_an_ignored_file.dart';
import 'package:pull_request_coverage/src/domain/analyzer/use_case/set_file_line_result_data.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/models/file_line.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/for_each_file_on_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/diff_reader/use_case/parse_git_diff.dart';
import 'package:pull_request_coverage/src/domain/input_reader/locv_reader/get_uncovered_file_lines.dart';
import 'package:pull_request_coverage/src/presentation/output_print_generator/output_generator.dart';
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
      FileLine(line: "int main(){", lineNumber: 1, isANewLine: true, isUntested: true, ignored: false),
      FileLine(line: "   print(\"oba\")", lineNumber: 2, isANewLine: true, isUntested: false, ignored: false),
      FileLine(line: "   return 0", lineNumber: 3, isANewLine: false, isUntested: true, ignored: false),
    ];

    final setUncoveredLines = _MockSetUncoveredLinesOnFileDiff();

    final analyze = _getAnalyze(
      parseGitHubDiff: _MockParseGitHubDiff(
        answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
      ),
      forEachFileOnGitDiff:
          _MockForEachFileOnGitDiff.dummy(List.generate(totalOfFilesOnDiff, (index) => ["file$index"])),
      getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 3]),
      setUncoveredLinesOnFileDiff: setUncoveredLines,
    );

    final analysisResult = analyze();

    test('Expect $totalOfFilesOnDiff uncovered lines reported by `analyze', () async {
      expect((await analysisResult).linesMissingTests, totalOfFilesOnDiff);
    });
    test('Expect $totalOfFilesOnDiff new lines reported by `analyze`', () async {
      expect((await analysisResult).linesShouldBeTested, 2 * totalOfFilesOnDiff);
    });
    test('expect to invoke `setUncoveredLines` for each file', () {
      verify(() => setUncoveredLines.call(any(), any())).called(totalOfFilesOnDiff);
    });
  });

  test("generated files should not count on results", () async {
    final linesOfEachFile = [
      FileLine(line: "int main(){", lineNumber: 1, isANewLine: true, isUntested: true, ignored: false),
    ];
    final analyze = _getAnalyze(
      parseGitHubDiff: _MockParseGitHubDiff(
        answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
      ),
      getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 2, 3, 4]),
      isAGeneratedFile: _MockIsAGeneratedFile.dummy(true),
    );
    final analyzeResult = await analyze();
    expect(analyzeResult.linesShouldBeTested, 0);
    expect(analyzeResult.untestedIgnoredLines, 0);
    expect(analyzeResult.linesMissingTests, 0);
  });

  test("ignored files should count for total of `untested lines that were ignored`", () async {
    final linesOfEachFile = [
      FileLine(line: "int main(){", lineNumber: 1, isANewLine: true, isUntested: true, ignored: false),
    ];
    final analyze = _getAnalyze(
      parseGitHubDiff: _MockParseGitHubDiff(
        answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
      ),
      getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 2, 3, 4]),
      isAnIgnoredFile: _MockIsAnIgnoredFile.dummy(true),
    );
    final analyzeResult = await analyze();
    expect(analyzeResult.linesShouldBeTested, 0);
    expect(analyzeResult.untestedIgnoredLines, 1);
    expect(analyzeResult.linesMissingTests, 0);
  });

  test(
    "ignored lines should count for totalOfIgnoredLinesMissingTests but not for totalOfNewLines nor totalOfUncoveredNewLines",
    () async {
      final linesOfEachFile = [
        FileLine(line: "int main(){", lineNumber: 1, isANewLine: true, isUntested: true, ignored: true),
        FileLine(line: "   print(\"oba\")", lineNumber: 2, isANewLine: true, isUntested: false, ignored: true),
        FileLine(line: "   return 0", lineNumber: 3, isANewLine: true, isUntested: true, ignored: true),
        FileLine(line: "   return 0", lineNumber: 4, isANewLine: true, isUntested: true, ignored: false),
      ];
      final analyze = _getAnalyze(
        parseGitHubDiff: _MockParseGitHubDiff(
          answer: FileDiff(path: '/var/tmp/ha.dart', lines: linesOfEachFile),
        ),
        getUncoveredFileLines: _MockGetUncoveredFileLines.dummy([1, 2, 3, 4]),
      );
      final analyzeResult = await analyze();
      expect(analyzeResult.linesShouldBeTested, 1);
      expect(analyzeResult.untestedIgnoredLines, 2);
      expect(analyzeResult.linesMissingTests, 1);
    },
  );
}

Analyze _getAnalyze({
  _MockParseGitHubDiff? parseGitHubDiff,
  _FakeIsAFileFromProject? isAFileFromProject,
  _MockGetUncoveredFileLines? getUncoveredFileLines,
  _MockForEachFileOnGitDiff? forEachFileOnGitDiff,
  _MockSetUncoveredLinesOnFileDiff? setUncoveredLinesOnFileDiff,
  _MockIsAGeneratedFile? isAGeneratedFile,
  _MockIsAnIgnoredFile? isAnIgnoredFile,
}) {
  return Analyze(
    parseGitDiff: parseGitHubDiff ?? _MockParseGitHubDiff(),
    forEachFileOnGitDiff: forEachFileOnGitDiff ??
        _MockForEachFileOnGitDiff.dummy([
          ["aho"]
        ]),
    lcovLines: [],
    setUncoveredLines: setUncoveredLinesOnFileDiff ?? _MockSetUncoveredLinesOnFileDiff(),
    getUncoveredFileLines: getUncoveredFileLines ?? _MockGetUncoveredFileLines(),
    outputGenerator: _MockOutputGenerator(),
    isAFileFromProject: isAFileFromProject ?? _FakeIsAFileFromProject(),
    isAGeneratedFile: isAGeneratedFile ?? _MockIsAGeneratedFile.dummy(false),
    isAnIgnoredFile: isAnIgnoredFile ?? _MockIsAnIgnoredFile.dummy(false),
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

class _MockOutputGenerator extends Mock implements OutputGenerator {}

class _FakeIsAFileFromProject extends Fake implements IsAFileFromProject {
  final bool response;

  _FakeIsAFileFromProject({this.response = true});

  @override
  bool call(String path) => response;
}
