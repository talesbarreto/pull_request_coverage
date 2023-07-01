import 'package:args/args.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_option_exceptions.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_option_register.dart';
import 'package:pull_request_coverage/src/extensions/string.dart';

class ArgDataSource implements UserOptionDataSource {
  final List<UserOptionRegister> availableOptions;

  final ArgParser argParser;

  ArgDataSource(this.argParser, this.availableOptions);

  ArgResults? _argResultsComputation;

  ArgResults get _argResults {
    if (_argResultsComputation == null) {
      throw Exception("`parse()` must be run before get any result from ArgDataSource");
    }
    return _argResultsComputation!;
  }

  void parse(List<String> arguments) {
    for (final option in availableOptions) {
      for (final name in option.names) {
        argParser.addOption(
          name,
          help: option.description,
          allowed: option.allowed,
        );
      }
    }
    try {
      _argResultsComputation = argParser.parse(arguments);
    } catch (e) {
      if (e is ArgParserException) {
        if (e.message.startsWith("Missing argument for")) {
          throw InvalidUserOptionsArg(arguments.first.removePrefix("--"), "command line");
        }
      }
      throw InvalidUserOptionException(arguments.first.removePrefix("--"), "command line");
    }
  }

  @override
  String? getString(UserOptionRegister userOptionsArgs) {
    for (final name in userOptionsArgs.names) {
      final value = _argResults[name];
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  @override
  T? get<T>(UserOptionRegister userOptionsArgs, T Function(String text) transform) {
    final result = getString(userOptionsArgs);
    if (result == null) {
      return null;
    }
    return transform(result);
  }

  @override
  List<String>? getStringList(UserOptionRegister userOptionsArgs) {
    return get(userOptionsArgs, (string) => string.split(","));
  }

  @override
  bool? getBoolean(UserOptionRegister userOptionsArgs) {
    final value = getString(userOptionsArgs);
    return value == null ? null : value == "true";
  }

  @override
  double? getDouble(UserOptionRegister userOptionsArgs) {
    final value = getString(userOptionsArgs);
    return value != null ? double.tryParse(value) : null;
  }

  @override
  int? getInt(UserOptionRegister userOptionsArgs) {
    final value = getString(userOptionsArgs);
    return value != null ? int.tryParse(value) : null;
  }
}
