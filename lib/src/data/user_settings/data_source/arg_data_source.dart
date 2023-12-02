import 'package:args/args.dart';
import 'package:pull_request_coverage/src/data/user_settings/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings_exceptions.dart';
import 'package:pull_request_coverage/src/domain/user_settings/user_settings_register.dart';
import 'package:pull_request_coverage/src/extensions/string.dart';

class ArgDataSource implements UserSettingsDataSource {
  final List<UserSettingsRegister> availableSettings;

  final ArgParser argParser;

  ArgDataSource(this.argParser, this.availableSettings);

  ArgResults? _argResultsComputation;

  ArgResults get _argResults {
    if (_argResultsComputation == null) {
      throw Exception("`parse()` must be run before get any result from ArgDataSource");
    }
    return _argResultsComputation!;
  }

  void parse(List<String> arguments) {
    for (final setting in availableSettings) {
      for (final name in setting.names) {
        argParser.addOption(
          name,
          help: setting.description,
          allowed: setting.allowed,
        );
      }
    }
    try {
      _argResultsComputation = argParser.parse(arguments);
    } catch (e) {
      if (e is ArgParserException) {
        if (e.message.startsWith("Missing argument for")) {
          throw InvalidUserSettingsArg(arguments.first.removePrefix("--"), "command line");
        }
      }
      throw InvalidUserSettingsException(arguments.first.removePrefix("--"), "command line");
    }
  }

  @override
  String? getString(UserSettingsRegister userSettingArgs) {
    for (final name in userSettingArgs.names) {
      final value = _argResults[name];
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  @override
  T? get<T>(UserSettingsRegister userSettingArgs, T Function(String text) transform) {
    final result = getString(userSettingArgs);
    if (result == null) {
      return null;
    }
    return transform(result);
  }

  @override
  List<String>? getStringList(UserSettingsRegister userSettingArgs) {
    return get(userSettingArgs, (string) => string.split(","));
  }

  @override
  bool? getBoolean(UserSettingsRegister userSettingArgs) {
    final value = getString(userSettingArgs);
    return value == null ? null : value == "true";
  }

  @override
  double? getDouble(UserSettingsRegister userSettingArgs) {
    final value = getString(userSettingArgs);
    return value != null ? double.tryParse(value) : null;
  }

  @override
  int? getInt(UserSettingsRegister userSettingArgs) {
    final value = getString(userSettingArgs);
    return value != null ? int.tryParse(value) : null;
  }
}
