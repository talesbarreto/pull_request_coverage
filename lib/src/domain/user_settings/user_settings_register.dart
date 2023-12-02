import 'package:pull_request_coverage/src/domain/user_settings/models/approval_requirement.dart';
import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

class UserSettingsRegister<T> {
  final List<String> names;
  final T defaultValue;
  final String? description;
  final List<String>? allowed;
  final bool isDeprecated;
  final UserSettingsArgType userSettingsArgType;

  const UserSettingsRegister({
    required this.names,
    required this.defaultValue,
    this.userSettingsArgType = UserSettingsArgType.string,
    this.description,
    this.allowed,
    this.isDeprecated = false,
  });

  // begin of consts

  static const options = <UserSettingsRegister>[
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
    approvalRequirement,
    logLevel,
  ];

  static List<String> getValidOptions() {
    return options.map((e) => e.names).toList().reduce((e1, e2) => [...e1, ...e2]);
  }

  static const lcovFile = UserSettingsRegister<String>(
    names: ["lcov-file"],
    description: "lcov.info file path",
    defaultValue: 'coverage/lcov.info',
  );

  static const excludeKnownGeneratedFiles = UserSettingsRegister<bool>(
    names: ["ignore-known-generated-files", "exclude-known-generated-files"],
    description: "Exclude generated files like `.g` or `.pb.dart`",
    defaultValue: true,
  );

  static const ignore = UserSettingsRegister(
    names: ["ignore", "exclude"],
    description: "Exclude files path that matches with Glob pattern",
    userSettingsArgType: UserSettingsArgType.list,
    defaultValue: null,
  );

  static const minimumCoverage = UserSettingsRegister(
    names: ["minimum-coverage"],
    description: "If the coverage is lower than this value, the test will fail",
    defaultValue: null,
  );

  static const maximumUncoveredLines = UserSettingsRegister(
    names: ["maximum-uncovered-lines"],
    description: "If there is more than this number of uncovered lines, the test will fail",
    defaultValue: null,
  );

  static const useColorfulOutput = UserSettingsRegister<bool>(
    names: ["use-colorful-output"],
    defaultValue: true,
  );

  static const showUncoveredCode = UserSettingsRegister<bool>(
    names: ["show-uncovered-code"],
    defaultValue: true,
  );

  static const reportFullyCoveredFiles = UserSettingsRegister<bool>(
    names: ["report-fully-covered-files"],
    defaultValue: true,
  );

  static const outputMode = UserSettingsRegister<String>(
    names: ["output-mode"],
    defaultValue: "cli",
    allowed: ["cli", "markdown"],
  );

  static const markdownMode = UserSettingsRegister<String>(
    names: ["markdown-mode"],
    defaultValue: "cli",
    allowed: ["diff", "dart"],
  );

  static const fractionDigits = UserSettingsRegister<int>(
    names: ["fraction-digits"],
    defaultValue: 2,
  );

  static const stdinTimeout = UserSettingsRegister<int>(
    names: ["stdin-timeout"],
    defaultValue: 1,
  );

  static const fullyTestedMessage = UserSettingsRegister(
    names: ["fully-tested-message"],
    defaultValue: null,
  );

  static const yamlConfigFilePath = UserSettingsRegister(
    names: ["config-file"],
    defaultValue: "pull_request_coverage.yaml",
  );

  static const ignoreLines = UserSettingsRegister<List<String>?>(
    names: ["ignore-lines"],
    userSettingsArgType: UserSettingsArgType.list,
    defaultValue: null,
  );

  static const generatedFiles = UserSettingsRegister<List<String>?>(
    names: ["generated-files"],
    userSettingsArgType: UserSettingsArgType.list,
    defaultValue: null,
  );

  static const knownGeneratedFiles = UserSettingsRegister<List<String>>(
    names: ["known-generated-files"],
    userSettingsArgType: UserSettingsArgType.list,
    defaultValue: [
      '**.g.dart',
      '**.pb.dart',
      '**.pbenum.dart',
      '**.pbserver.dart',
      '**.pbjson.dart',
    ],
  );

  static const addToKnownGeneratedFiles = UserSettingsRegister<List<String>>(
    names: ["add-to-known-generated-files"],
    userSettingsArgType: UserSettingsArgType.list,
    defaultValue: [],
  );

  static const printEmojis = UserSettingsRegister<bool>(
    names: ["print-emojis"],
    description: "Use emojis in the output",
    defaultValue: true,
  );

  static const approvalRequirement = UserSettingsRegister<ApprovalRequirement>(
    names: ["approval-requirement"],
    description:
        "when both minimum-coverage and maximum-uncovered-lines are specified, the approval-requirement determines the conditions for passing the tests.",
    defaultValue: ApprovalRequirement.linesAndRate,
    allowed: ["lines-and-rate", "lines-or-rate"],
  );

  static const logLevel = UserSettingsRegister<LogLevel>(
    names: ["log-level"],
    description: "Internal log level",
    defaultValue: LogLevel.none,
  );
}

enum UserSettingsArgType {
  string,
  list,
}
