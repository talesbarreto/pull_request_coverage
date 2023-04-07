generate-cli-example:
	cat input_samples/sample1/git.diff | dart bin/pull_request_coverage.dart --lcov-file input_samples/sample1/lcov.info  --maximum-uncovered-lines 5 --minimum-coverage 99

generate-markdown-example:
	cat input_samples/sample1/git.diff | dart bin/pull_request_coverage.dart --lcov-file input_samples/sample1/lcov.info  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown

generate-markdown-dart-example:
	cat input_samples/sample1/git.diff | dart bin/pull_request_coverage.dart --lcov-file input_samples/sample1/lcov.info  --maximum-uncovered-lines 5 --minimum-coverage 99 --output-mode markdown --markdown-mode dart

gen-coverage:
	dart ci/generate_coverage_helper.dart
	dart pub global run coverage:test_with_coverage

tests:
	dart test
	dart test integration_test