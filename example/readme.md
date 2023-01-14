### CLI output

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99    
```
#### Output example

<img width="827" alt="Screenshot 2023-01-14 at 11 05 26" src="https://user-images.githubusercontent.com/7644323/212476070-6e4d3c02-de8f-4771-9f9a-33ff854fee8e.png">

You can disable the colors using `--use-colorful-output false`

____
### Markdown output

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown    
```

#### Output example
- `lib/src/presentation/output_print_generator/cli_output_generator.dart` is fully covered (+16)
- `lib/src/presentation/output_print_generator/cli_table_builder.dart` has 6 uncovered lines (+59)
```diff
  25:   String build() {
  26:     final stringBuffer = StringBuffer();
  27:     final columnSize = List.generate(columnsLength, (index) => 0);
- 28:     for (var columnIndex = 0; columnIndex < columnsLength; columnIndex++) {
- 29:       for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {
- 30:         if (table[lineIndex][columnIndex].length > columnSize[columnIndex]) {
- 31:           columnSize[columnIndex] = table[lineIndex][columnIndex].length;
  32:         }
  33:       }
  34:     }
```
```diff
  43:       }
  44:       stringBuffer.writeln();
  45:       for (var i = 0; i < header.length; i++) {
- 46:         stringBuffer.write(_createContent("", columnSize[i], "-"));
- 47:         stringBuffer.write(columnDivider);
  48:       }
  49:     }
  50:     for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {
```
- `lib/src/presentation/output_print_generator/markdown_output_generator.dart` is fully covered (+14)
- `lib/src/presentation/output_print_generator/output_generator.dart` is fully covered (+1)
### Report
|                                          | Current value | Threshold | Result   |
|------------------------------------------|---------------|-----------|----------|
| Lines that should be tested under `/lib` | 89            |           |          |
| Uncovered new lines                      | 6             | 5         | **FAIL** |
| Coverage rate                            | 93.26%        | 99.0%     | **FAIL** |

____
### Markdown output using `dart` mode

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown --markdown-mode dart 
```

#### Output example
- `lib/src/presentation/output_print_generator/cli_output_generator.dart` is fully covered (+16)
- `lib/src/presentation/output_print_generator/cli_table_builder.dart` has 6 uncovered lines (+59)
```dart
  String build() {
    final stringBuffer = StringBuffer();
    final columnSize = List.generate(columnsLength, (index) => 0);
    for (var columnIndex = 0; columnIndex < columnsLength; columnIndex++) {	// <- MISSING TEST AT LINE 28
      for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {	// <- MISSING TEST AT LINE 29
        if (table[lineIndex][columnIndex].length > columnSize[columnIndex]) {	// <- MISSING TEST AT LINE 30
          columnSize[columnIndex] = table[lineIndex][columnIndex].length;	// <- MISSING TEST AT LINE 31
        }
      }
    }
```
```dart
      }
      stringBuffer.writeln();
      for (var i = 0; i < header.length; i++) {
        stringBuffer.write(_createContent("", columnSize[i], "-"));	// <- MISSING TEST AT LINE 46
        stringBuffer.write(columnDivider);	// <- MISSING TEST AT LINE 47
      }
    }
    for (var lineIndex = 0; lineIndex < table.length; lineIndex++) {
```
- `lib/src/presentation/output_print_generator/markdown_output_generator.dart` is fully covered (+14)
- `lib/src/presentation/output_print_generator/output_generator.dart` is fully covered (+1)
### Report
|                                          | Current value | Threshold | Result   |
|------------------------------------------|---------------|-----------|----------|
| Lines that should be tested under `/lib` | 89            |           |          |
| Uncovered new lines                      | 6             | 5         | **FAIL** |
| Coverage rate                            | 93.26%        | 99.0%     | **FAIL** |

____