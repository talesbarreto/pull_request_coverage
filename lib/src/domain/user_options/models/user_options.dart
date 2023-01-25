import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';

class UserOptions {
  final List<String> excludePrefixPaths;
  final List<String> excludeSuffixPaths;
  final String lcovFilePath;
  final String? fullyTestedMessage;
  final double? minimumCoverageRate;
  final int? maximumUncoveredLines;
  final bool showUncoveredCode;
  final bool useColorfulOutput;
  final bool reportFullyCoveredFiles;
  final OutputMode outputMode;
  final MarkdownMode markdownMode;
  final int fractionalDigits;

  /// [fractionalDigits] how many digits after the decimal point to show on coverage rate
  const UserOptions({
    required this.excludePrefixPaths,
    required this.excludeSuffixPaths,
    required this.lcovFilePath,
    required this.showUncoveredCode,
    required this.outputMode,
    required this.fractionalDigits,
    required this.markdownMode,
    this.fullyTestedMessage,
    this.minimumCoverageRate,
    this.maximumUncoveredLines,
    this.useColorfulOutput = true,
    this.reportFullyCoveredFiles = true,
  });
}
