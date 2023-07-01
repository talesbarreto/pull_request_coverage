import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

class UserOptionRegister<T> {
  final List<String> names;
  final T defaultValue;
  final String? description;
  final List<String>? allowed;
  final bool isDeprecated;
  final UserOptionsArgType userOptionsArgType;

  const UserOptionRegister({
    required this.names,
    required this.defaultValue,
    this.userOptionsArgType = UserOptionsArgType.string,
    this.description,
    this.allowed,
    this.isDeprecated = false,
  });

  // begin of consts

  static const options = <UserOptionRegister>[
    lcovFile,
    excludeKnownGeneratedFiles,
    ignore,
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
    generatedFiles,
    addToKnownGeneratedFiles,
    knownGeneratedFiles,
    printEmojis,
    logLevel,
  ];

  static List<String> getValidOptions() {
    return options.map((e) => e.names).toList().reduce((e1, e2) => [...e1, ...e2]);
  }

  static const lcovFile = UserOptionRegister<String>(
    names: ["lcov-file"],
    description: "lcov.info file path",
    defaultValue: 'coverage/lcov.info',
  );

  static const excludeKnownGeneratedFiles = UserOptionRegister<bool>(
    names: ["ignore-known-generated-files", "exclude-known-generated-files"],
    description: "Exclude generated files like `.g` or `.pb.dart`",
    defaultValue: true,
  );

  static const ignore = UserOptionRegister(
    names: ["ignore", "exclude"],
    description: "Exclude files path that matches with Glob pattern",
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: null,
  );

  static const minimumCoverage = UserOptionRegister(
    names: ["minimum-coverage"],
    description: "If the coverage is lower than this value, the test will fail",
    defaultValue: null,
  );

  static const maximumUncoveredLines = UserOptionRegister(
    names: ["maximum-uncovered-lines"],
    description: "If there is more than this number of uncovered lines, the test will fail",
    defaultValue: null,
  );

  static const useColorfulOutput = UserOptionRegister<bool>(
    names: ["use-colorful-output"],
    defaultValue: true,
  );

  static const showUncoveredCode = UserOptionRegister<bool>(
    names: ["show-uncovered-code"],
    defaultValue: true,
  );

  static const reportFullyCoveredFiles = UserOptionRegister<bool>(
    names: ["report-fully-covered-files"],
    defaultValue: true,
  );

  static const outputMode = UserOptionRegister<String>(
    names: ["output-mode"],
    defaultValue: "cli",
    allowed: ["cli", "markdown"],
  );

  static const markdownMode = UserOptionRegister<String>(
    names: ["markdown-mode"],
    defaultValue: "cli",
    allowed: ["diff", "dart"],
  );

  static const fractionDigits = UserOptionRegister<int>(
    names: ["fraction-digits"],
    defaultValue: 2,
  );

  static const stdinTimeout = UserOptionRegister<int>(
    names: ["stdin-timeout"],
    defaultValue: 1,
  );

  static const fullyTestedMessage = UserOptionRegister(
    names: ["fully-tested-message"],
    defaultValue: null,
  );

  static const yamlConfigFilePath = UserOptionRegister(
    names: ["config-file"],
    defaultValue: "pull_request_coverage.yaml",
  );

  static const ignoreLines = UserOptionRegister<List<String>?>(
    names: ["ignore-lines"],
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: null,
  );

  static const generatedFiles = UserOptionRegister<List<String>?>(
    names: ["generated-files"],
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: null,
  );

  static const knownGeneratedFiles = UserOptionRegister<List<String>>(
    names: ["known-generated-files"],
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: [
      '**.g.dart',
      '**.pb.dart',
      '**.pbenum.dart',
      '**.pbserver.dart',
      '**.pbjson.dart',
    ],
  );

  static const addToKnownGeneratedFiles = UserOptionRegister<List<String>>(
    names: ["add-to-known-generated-files"],
    userOptionsArgType: UserOptionsArgType.list,
    defaultValue: [],
  );

  static const printEmojis = UserOptionRegister<bool>(
    names: ["print-emojis"],
    description: "Use emojis in the output",
    defaultValue: true,
  );

  static const logLevel = UserOptionRegister<LogLevel>(
    names: ["log-level"],
    description: "Internal log level",
    defaultValue: LogLevel.none,
  );
}

enum UserOptionsArgType {
  string,
  list,
}
