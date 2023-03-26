class UserOptionsArgs<T> {
  final String name;
  final T defaultValue;
  final String? description;
  final List<String>? allowed;
  final bool isDeprecated;
  final UserOptionsArgType userOptionsArgType;

  const UserOptionsArgs({
    required this.name,
    required this.defaultValue,
    this.userOptionsArgType = UserOptionsArgType.string,
    this.description,
    this.allowed,
    this.isDeprecated = false,
  });

  // begin of consts

  static const knownGeneratedFiles = [
    '**.g.dart',
    '**.pb.dart',
    '**.pbenum.dart',
    '**.pbserver.dart',
    '**.pbjson.dart',
  ];

  static const options = <UserOptionsArgs>[
    lcovFile,
    excludeKnownGeneratedFiles,
    exclude,
    minimumCoverage,
    maximumUncoveredLines,
    useColorfulOutput,
    showUncoveredCode,
    reportFullyCoveredFiles,
    outputMode,
    markdownMode,
    fractionDigits,
    stdinTimeout,
    fullyTestedMessage,
    yamlConfigFilePath,
  ];

  static const lcovFile = UserOptionsArgs<String>(
    name: "lcov-file",
    description: "lcov.info file path",
    defaultValue: 'coverage/lcov.info',
  );
  static const excludeKnownGeneratedFiles = UserOptionsArgs<bool>(
    name: "exclude-known-generated-files",
    description: "Exclude generated files like `.g` or `.pb.dart`",
    defaultValue: true,
  );
  static const exclude = UserOptionsArgs(
    name: "exclude",
    description: "Exclude files path that matches with Glob pattern",
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: null,
  );
  static const minimumCoverage = UserOptionsArgs(
    name: "minimum-coverage",
    description: "If the coverage is lower than this value, the test will fail",
    defaultValue: null,
  );
  static const maximumUncoveredLines = UserOptionsArgs(
    name: "maximum-uncovered-lines",
    description: "If there is more than this number of uncovered lines, the test will fail",
    defaultValue: null,
  );
  static const useColorfulOutput = UserOptionsArgs<bool>(
    name: "use-colorful-output",
    defaultValue: true,
  );
  static const showUncoveredCode = UserOptionsArgs<bool>(
    name: "show-uncovered-code",
    defaultValue: true,
  );
  static const reportFullyCoveredFiles = UserOptionsArgs<bool>(
    name: "report-fully-covered-files",
    defaultValue: true,
  );
  static const outputMode = UserOptionsArgs<String>(
    name: "output-mode",
    defaultValue: "cli",
    allowed: ["cli", "markdown"],
  );
  static const markdownMode = UserOptionsArgs<String>(
    name: "markdown-mode",
    defaultValue: "cli",
    allowed: ["diff", "dart"],
  );
  static const fractionDigits = UserOptionsArgs<int>(
    name: "fraction-digits",
    defaultValue: 2,
  );
  static const stdinTimeout = UserOptionsArgs<int>(
    name: "stdin-timeout",
    defaultValue: 1,
  );
  static const fullyTestedMessage = UserOptionsArgs(
    name: "fully-tested-message",
    defaultValue: null,
  );
  static const yamlConfigFilePath = UserOptionsArgs(
    name: "config-file",
    defaultValue: "pull_request_coverage.yaml",
  );
}

enum UserOptionsArgType {
  string,
  list,
}
