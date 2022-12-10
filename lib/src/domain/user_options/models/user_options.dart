import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';

class UserOptions {
  final List<String> excludePrefixPaths;
  final List<String> excludeSuffixPaths;
  final String lcovFilePath;
  final double? minimumCoverageRate;
  final int? maximumUncoveredLines;
  final bool showUncoveredCode;
  final bool useColorfulOutput;
  final bool reportFullyCoveredFiles;
  final OutputMode outputMode;

  const UserOptions({
    required this.excludePrefixPaths,
    required this.excludeSuffixPaths,
    required this.lcovFilePath,
    required this.showUncoveredCode,
    required this.outputMode,
    this.minimumCoverageRate,
    this.maximumUncoveredLines,
    this.useColorfulOutput = true,
    this.reportFullyCoveredFiles = true,
  });
}
