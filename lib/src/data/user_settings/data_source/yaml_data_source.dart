import 'package:pull_request_coverage/src/data/user_settings/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings_exceptions.dart';
import 'package:pull_request_coverage/src/domain/user_settings/user_settings_register.dart';
import 'package:yaml/yaml.dart';

class YamlDataSource implements UserSettingsDataSource {
  YamlMap? _yamlMapComputation;

  YamlMap get _yamlMap {
    if (_yamlMapComputation == null) {
      throw Exception("`parse()` must be run before get any result from YamlDataSource");
    }
    return _yamlMapComputation!;
  }

  void parse(String yaml) {
    _yamlMapComputation = loadYaml(yaml);
  }

  void throwExceptionOnInvalidUserSettings(List<String> options) {
    if (_yamlMapComputation != null) {
      for (final option in _yamlMap.keys) {
        if (!options.contains(option.toString())) {
          throw InvalidUserSettingsException(option, "yaml file");
        }
      }
    }
  }

  T? _get<T>(UserSettingsRegister userSettingArgs) {
    for (final name in userSettingArgs.names) {
      final value = _yamlMap[name];
      if (value != null) {
        if (value is T) {
          return value;
        } else {
          throw Exception("Expect `$name` of type ${T.toString()} but `$value` is ${value.runtimeType}");
        }
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
  String? getString(UserSettingsRegister userSettingArgs) {
    return _get<String>(userSettingArgs);
  }

  @override
  List<String>? getStringList(UserSettingsRegister userSettingArgs) {
    final result = _get<YamlList>(userSettingArgs);
    if (result == null) {
      return null;
    }
    return result.toList(growable: false).whereType<String>().toList(growable: false);
  }

  @override
  bool? getBoolean(UserSettingsRegister userSettingArgs) {
    return _get<bool>(userSettingArgs);
  }

  @override
  double? getDouble(UserSettingsRegister userSettingArgs) {
    final result = _get<Object>(userSettingArgs);
    if (result is double) {
      return result;
    }
    if (result is int) {
      return result.toDouble();
    }

    return null;
  }

  @override
  int? getInt(UserSettingsRegister userSettingArgs) {
    final result = _get<Object>(userSettingArgs);
    if (result is int) {
      return result;
    }
    if (result is double) {
      return result.toInt();
    }

    return null;
  }
}
