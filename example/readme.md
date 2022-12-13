### CLI output

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode cli    
```

CLI is the default output-mode. It is not necessary to specify it.

You can disable the colors using `--use-colorful-output false`

<img width="758" alt="Screenshot 2022-12-10 at 10 43 18" src="https://user-images.githubusercontent.com/7644323/206858399-4b5f0261-c832-428b-acf5-7e0ad74c5d60.png">

____
### Markdown output

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown    
```

#### Output example
- `lib/src/presentation/use_case/print_analyze_result.dart` has 1 uncovered lines (+3)
```diff
  10:  
  11:    void call(AnalysisResult analysisResult, UserOptions userOptions) {
  12:      if (analysisResult.totalOfNewLines == 0) {
- 13:       print("This pull request has no new lines");
  14:        return;
  15:      }
  16:  
```

After ignoring excluded files, this pull request has:
- 236 new lines, 94 of them are NOT covered by tests. **You can only have up to 5 uncovered lines**
- 60.16949152542372% of coverage. **You need at least 99.0% of coverage**

____
### Markdown output using `dart` mode

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown --markdown-mode dart 
```

#### Output example
- `lib/src/presentation/use_case/print_analyze_result.dart` has 1 uncovered lines (+3)

```dart

void call(AnalysisResult analysisResult, UserOptions userOptions) {
  if (analysisResult.totalOfNewLines == 0) {
    print("This pull request has no new lines");	// <- MISSING TEST AT LINE 13
    return;
  }

```

After ignoring excluded files, this pull request has:
- 236 new lines, 94 of them are NOT covered by tests. You can only have up to 5 uncovered lines
- 60.16949152542372% of coverage. You need at least 99.0% of coverage

____