generate-cli-example:
	cat input_samples/sample1/git.diff | dart bin/pull_request_coverage.dart --lcov-file input_samples/sample1/lcov.info  --maximum-uncovered-lines 5 --minimum-coverage 99

generate-markdown-example:
	cat input_samples/sample1/git.diff | dart bin/pull_request_coverage.dart --lcov-file input_samples/sample1/lcov.info  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown

generate-markdown-dart-example:
	cat input_samples/sample1/git.diff | dart bin/pull_request_coverage.dart --lcov-file input_samples/sample1/lcov.info  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown --markdown-mode dart