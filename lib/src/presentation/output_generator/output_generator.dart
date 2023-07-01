import 'package:pull_request_coverage/src/domain/analyzer/models/analysis_result.dart';
import 'package:pull_request_coverage/src/domain/analyzer/models/file_report.dart';
import 'package:pull_request_coverage/src/presentation/use_case/print_emoji.dart';

abstract class OutputGenerator {
  static const skipEmoji = "🐇";
  static const celebratingEmoji = "🎉";
  static const warningEmoji = "🚨";
  static const successEmoji = "✅";
  static const failEmoji = "❌";

  void addFileReport(FileReport report);

  void terminate(AnalysisResult analysisResult);

  static SurroundingEmojis getFileHeaderSurroundingEmojis({
    required PrintEmoji printEmoji,
    required bool hasMissingTestLines,
    required bool hasIgnoredUntestedLines,
    required bool hasNewLines,
  }) {
    final prefixEmoji = hasMissingTestLines ? printEmoji("${OutputGenerator.warningEmoji} ", "") : "";
    final suffixEmoji = hasMissingTestLines
        ? ""
        : hasIgnoredUntestedLines
            ? ""
            : hasNewLines
                ? printEmoji(OutputGenerator.celebratingEmoji, "")
                : "";
    return SurroundingEmojis(prefixEmoji, suffixEmoji);
  }
}

class SurroundingEmojis {
  final String prefix;
  final String suffix;

  const SurroundingEmojis(this.prefix, this.suffix);
}
