import 'package:args/args.dart';
import 'package:glob/glob.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/markdown_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/output_mode.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';

class UserOptionsRepositoryImpl implements UserOptionsRepository {
  static const defaultLcovFile = "coverage/lcov.info";
  static const knownGeneratedFiles = [
    '**.g.dart',
    '**.pb.dart',
    '**.pbenum.dart',
    '**.pbserver.dart',
    '**.pbjson.dart',
  ];

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
      // deprecated
      "exclude-suffix",
      help: "Exclude files path with those suffix, separated by comma",
    );
    argParser.addOption(
      // deprecated
      "exclude-prefix",
      help: "Exclude files path with those prefix, separated by comma",
    );
    argParser.addOption(
      "exclude-known-generated-files",
      help: "Exclude all $knownGeneratedFiles files",
      defaultsTo: "true",
    );
    argParser.addOption(
      "exclude",
      help: "Exclude files path that matches with Glob pattern, separate by comma",
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
    argParser.addOption(
      "stdin-timeout",
      defaultsTo: "1",
    );
    argParser.addOption(
      "fully-tested-message",
    );
  }

  List<Glob> _parseGlob(List<String> patterns) {
    try {
      return List.generate(patterns.length, (index) => Glob(patterns[index]), growable: false);
    } catch (e) {
      throw Exception("Glob parser error: $e");
    }
  }

  List<Glob> _parseExclude(ArgResults argResults) {
    final excludeKnownGeneratedFiles = argResults["exclude-known-generated-files"] == "true";
    final prefixes = (argResults["exclude-prefix"] as String?)?.split(",").toList(growable: false) ?? [];
    final suffixes = (argResults["exclude-suffix"] as String?)?.split(",").toList(growable: false) ?? [];
    final exclude = (argResults["exclude"] as String?)?.split(",").toList(growable: false) ?? [];
    return [
      if (excludeKnownGeneratedFiles) ..._parseGlob(knownGeneratedFiles),
      ..._parseGlob(prefixes.map((pattern) => "$pattern**").toList(growable: false)),
      ..._parseGlob(exclude),
      ..._parseGlob(suffixes.map((pattern) => "**$pattern").toList(growable: false)),
    ];
  }

  @override
  Result<UserOptions> getUserOptions(List<String> arguments) {
    try {
      _registerAvailableOptions();
      final argResults = argParser.parse(arguments);

      return ResultSuccess(
        UserOptions(
          excludeFile: _parseExclude(argResults),
          lcovFilePath: argResults["lcov-file"],
          minimumCoverageRate:
              argResults["minimum-coverage"] != null ? double.tryParse(argResults["minimum-coverage"]) : null,
          maximumUncoveredLines: argResults["maximum-uncovered-lines"] != null
              ? int.tryParse(argResults["maximum-uncovered-lines"])
              : null,
          showUncoveredCode: argResults["show-uncovered-code"] == "true",
          useColorfulOutput: argResults["use-colorful-output"] == "true",
          reportFullyCoveredFiles: argResults["report-fully-covered-files"] == "true",
          outputMode: argResults["output-mode"] == "markdown" ? OutputMode.markdown : OutputMode.cli,
          fractionalDigits: int.tryParse(argResults["fraction-digits"]) ?? 2,
          markdownMode: argResults["markdown-mode"] == "dart" ? MarkdownMode.dart : MarkdownMode.diff,
          fullyTestedMessage: argResults["fully-tested-message"],
          stdinTimeout: Duration(seconds: int.tryParse(argResults["stdin-timeout"]) ?? 1),
          deprecatedFilterSet: argResults["exclude-prefix"] != null || argResults["exclude-suffix"] != null,
        ),
      );
    } catch (e) {
      return ResultError(e.toString());
    }
  }
}
