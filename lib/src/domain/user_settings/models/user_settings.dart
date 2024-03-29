import 'package:glob/glob.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/approval_requirement.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/output_mode.dart';
import 'package:pull_request_coverage/src/presentation/logger/log_level.dart';

class UserSettings {
  final List<Glob> ignoredFiles;
  final List<Glob> knownGeneratedFiles;
  final String lcovFilePath;
  final String? fullyTestedMessage;
  final double? minimumCoverageRate;
  final int? maximumUncoveredLines;
  final bool showUncoveredCode;
  final bool useColorfulOutput;
  final bool ignoreKnownGeneratedFiles;
  final bool reportFullyCoveredFiles;
  final bool useEmojis;
  final OutputMode outputMode;
  final MarkdownMode markdownMode;
  final int fractionalDigits;
  final Duration stdinTimeout;
  final bool deprecatedFilterSet;
  final List<RegExp> lineFilters;
  final ApprovalRequirement approvalRequirement;
  final LogLevel logLevel;

  /// [fractionalDigits] how many digits after the decimal point to show on coverage rate
  const UserSettings({
    this.ignoredFiles = const [],
    this.lcovFilePath = "coverage/lcov.info",
    this.showUncoveredCode = true,
    this.outputMode = OutputMode.cli,
    this.fractionalDigits = 3,
    this.markdownMode = MarkdownMode.diff,
    this.fullyTestedMessage,
    this.knownGeneratedFiles = const [],
    this.minimumCoverageRate,
    this.maximumUncoveredLines,
    this.useColorfulOutput = true,
    this.ignoreKnownGeneratedFiles = true,
    this.reportFullyCoveredFiles = true,
    this.stdinTimeout = const Duration(seconds: 1),
    this.deprecatedFilterSet = false,
    this.lineFilters = const [],
    this.useEmojis = true,
    this.logLevel = LogLevel.none,
    this.approvalRequirement = ApprovalRequirement.linesAndRate,
  });
}
