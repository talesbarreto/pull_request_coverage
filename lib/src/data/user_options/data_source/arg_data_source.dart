import 'package:args/args.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_options_args.dart';

class ArgDataSource implements UserOptionDataSource {
  final List<UserOptionsArgs> availableOptions;

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
    _argResultsComputation = argParser.parse(arguments);
  }

  @override
  String? getString(UserOptionsArgs userOptionsArgs) {
    for (final name in userOptionsArgs.names) {
      final value = _argResults[name];
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  @override
  T? get<T>(UserOptionsArgs userOptionsArgs, T Function(String text) transform) {
    final result = getString(userOptionsArgs);
    if (result == null) {
      return null;
    }
    return transform(result);
  }

  @override
  List<String>? getStringList(UserOptionsArgs userOptionsArgs) {
    return get(userOptionsArgs, (string) => string.split(","));
  }

  @override
  bool? getBoolean(UserOptionsArgs userOptionsArgs) {
    final value = getString(userOptionsArgs);
    return value == null ? null : value == "true";
  }

  @override
  double? getDouble(UserOptionsArgs userOptionsArgs) {
    final value = getString(userOptionsArgs);
    return value != null ? double.tryParse(value) : null;
  }

  @override
  int? getInt(UserOptionsArgs userOptionsArgs) {
    final value = getString(userOptionsArgs);
    return value != null ? int.tryParse(value) : null;
  }
}
