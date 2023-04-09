### CLI output

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99    
```
#### Output example

![Screenshot 2023-04-09 at 11 08 01](https://user-images.githubusercontent.com/7644323/230777531-9a845de5-09a8-4914-b8a6-7ead78d7cb9e.png)

You can disable the colors using `--use-colorful-output false`

____
### Markdown output

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown    
```

#### Output example
- `lib/src/presentation/output_print_generator/cli_output_generator.dart` (+16)
- `lib/src/presentation/output_print_generator/cli_table_builder.dart` (+59) / **6 lines missing tests**
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
- `lib/src/presentation/output_print_generator/markdown_output_generator.dart` (+14)
- `lib/src/presentation/output_print_generator/output_generator.dart` (+1)

|           Report            | Current value | Threshold |      |
|-----------------------------|---------------|-----------|------|
| Lines that should be tested |      89       |           |      |
|   Ignored untested lines    |       0       |           |      |
|                             |               |           |      |
|     Lines missing tests     |       6       |     5     | FAIL |
|        Coverage rate        |    93.26%     |   99.0%   | FAIL |
____
### Markdown output using `dart` mode

```bash
flutter test --coverage
git diff origin/main | dart bin/pull_request_coverage.dart  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown --markdown-mode dart 
```

#### Output example
- `lib/src/presentation/output_print_generator/cli_output_generator.dart` (+16)
- `lib/src/presentation/output_print_generator/cli_table_builder.dart` (+59) / **6 lines missing tests**
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
- `lib/src/presentation/output_print_generator/markdown_output_generator.dart` (+14)
- `lib/src/presentation/output_print_generator/output_generator.dart` (+1)

|           Report            | Current value | Threshold |      |
|-----------------------------|---------------|-----------|------|
| Lines that should be tested |      89       |           |      |
|   Ignored untested lines    |       0       |           |      |
|                             |               |           |      |
|     Lines missing tests     |       6       |     5     | FAIL |
|        Coverage rate        |    93.26%     |   99.0%   | FAIL |

____