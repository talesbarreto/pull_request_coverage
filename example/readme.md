This package is intended to be used as a CI step or as a command line tool.
Example:

```bash
git diff repository/main | flutter pub run pull_request_coverage --minimum-coverage 95 --maximum-uncovered-lines 5 --hide-uncovered-lines
```

