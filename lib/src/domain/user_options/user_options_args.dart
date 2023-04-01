class UserOptionsArgs<T> {
  final List<String> names;
  final T defaultValue;
  final String? description;
  final List<String>? allowed;
  final bool isDeprecated;
  final UserOptionsArgType userOptionsArgType;

  const UserOptionsArgs({
    required this.names,
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
    ignoreLines,
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
    names: ["lcov-file"],
    description: "lcov.info file path",
    defaultValue: 'coverage/lcov.info',
  );
  static const excludeKnownGeneratedFiles = UserOptionsArgs<bool>(
    names: ["ignore-known-generated-files", "exclude-known-generated-files"],
    description: "Exclude generated files like `.g` or `.pb.dart`",
    defaultValue: true,
  );
  static const exclude = UserOptionsArgs(
    names: ["ignore", "exclude"],
    description: "Exclude files path that matches with Glob pattern",
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: null,
  );
  static const minimumCoverage = UserOptionsArgs(
    names: ["minimum-coverage"],
    description: "If the coverage is lower than this value, the test will fail",
    defaultValue: null,
  );
  static const maximumUncoveredLines = UserOptionsArgs(
    names: ["maximum-uncovered-lines"],
    description: "If there is more than this number of uncovered lines, the test will fail",
    defaultValue: null,
  );
  static const useColorfulOutput = UserOptionsArgs<bool>(
    names: ["use-colorful-output"],
    defaultValue: true,
  );
  static const showUncoveredCode = UserOptionsArgs<bool>(
    names: ["show-uncovered-code"],
    defaultValue: true,
  );
  static const reportFullyCoveredFiles = UserOptionsArgs<bool>(
    names: ["report-fully-covered-files"],
    defaultValue: true,
  );
  static const outputMode = UserOptionsArgs<String>(
    names: ["output-mode"],
    defaultValue: "cli",
    allowed: ["cli", "markdown"],
  );
  static const markdownMode = UserOptionsArgs<String>(
    names: ["markdown-mode"],
    defaultValue: "cli",
    allowed: ["diff", "dart"],
  );
  static const fractionDigits = UserOptionsArgs<int>(
    names: ["fraction-digits"],
    defaultValue: 2,
  );
  static const stdinTimeout = UserOptionsArgs<int>(
    names: ["stdin-timeout"],
    defaultValue: 1,
  );
  static const fullyTestedMessage = UserOptionsArgs(
    names: ["fully-tested-message"],
    defaultValue: null,
  );
  static const yamlConfigFilePath = UserOptionsArgs(
    names: ["config-file"],
    defaultValue: "pull_request_coverage.yaml",
  );
  static const ignoreLines = UserOptionsArgs(
    names: ["ignore-lines"],
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: null,
  );
}

enum UserOptionsArgType {
  string,
  list,
}
