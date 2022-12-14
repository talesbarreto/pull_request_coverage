import 'package:args/args.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';

class UserOptionsRepositoryImpl implements UserOptionsRepository {
  static const defaultLcovFile = "coverage/lcov.info";
  static const defaultExcludeSuffix = ".g.dart,.pb.dart,.pbenum.dart,.pbserver.dart,.pbjson.dart";

  final ArgParser argParser;

  UserOptionsRepositoryImpl(this.argParser);

  bool optionsRegistered = false;

  void _registerAvailableOptions() {
    if (optionsRegistered) {
      return;
    }
    optionsRegistered = true;
    argParser.addOption(
      "lcov-file",
      mandatory: false,
      help: "lcov.info file path",
      defaultsTo: defaultLcovFile,
    );
    argParser.addOption(
      "exclude-suffix",
      help: "Exclude files path with those suffix, separated by comma",
      defaultsTo: defaultExcludeSuffix,
    );
    argParser.addOption(
      "exclude-prefix",
      help: "Exclude files path with those prefix, separated by comma",
      defaultsTo: defaultLcovFile,
    );
    argParser.addOption(
      "minimum-coverage",
      help: "If the coverage is lower than this value, the test will fail",
    );
    argParser.addOption(
      "maximum-uncovered-lines",
      help: "If there is more than this number of uncovered lines, the test will fail",
    );
    argParser.addOption(
      "use-colorful-output",
      defaultsTo: "true",
    );
    argParser.addOption(
      "show-uncovered-code",
      defaultsTo: "true",
    );
    argParser.addOption(
      "report-fully-covered-files",
      defaultsTo: "true",
    );
    argParser.addOption(
      "output-mode",
      defaultsTo: "cli",
      allowed: ["cli", "markdown"],
    );
    argParser.addOption(
      "markdown-mode",
      defaultsTo: "cli",
      allowed: ["diff", "dart"],
    );
    argParser.addOption(
      "fraction-digits",
      defaultsTo: "2",
    );
  }

  @override
  Result<UserOptions> getUserOptions(List<String> arguments) {
    try {
      _registerAvailableOptions();
      final result = argParser.parse(arguments);

      return ResultSuccess(
        UserOptions(
          excludePrefixPaths: result["exclude-prefix"]?.toLowerCase().split(",").toList(growable: false) ?? [],
          excludeSuffixPaths: result["exclude-suffix"]?.toLowerCase().split(",").toList(growable: false) ?? [],
          lcovFilePath: result["lcov-file"],
          minimumCoverageRate: result["minimum-coverage"] != null ? double.tryParse(result["minimum-coverage"]) : null,
          maximumUncoveredLines: result["maximum-uncovered-lines"] != null ? int.tryParse(result["maximum-uncovered-lines"]) : null,
          showUncoveredCode: result["show-uncovered-code"] == "true",
          useColorfulOutput: result["use-colorful-output"] == "true",
          reportFullyCoveredFiles: result["report-fully-covered-files"] == "true",
          outputMode: result["output-mode"] == "markdown" ? OutputMode.markdown : OutputMode.cli,
          fractionalDigits: int.tryParse(result["fraction-digits"]) ?? 2,
          markdownMode: result["markdown-mode"] == "dart" ? MarkdownMode.dart : MarkdownMode.diff,
        ),
      );
    } catch (e) {
      return ResultError(e.toString());
    }
  }
}
