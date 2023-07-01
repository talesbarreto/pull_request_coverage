import 'package:pull_request_coverage/src/data/user_options/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_option_exceptions.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_option_register.dart';
import 'package:yaml/yaml.dart';

class YamlDataSource implements UserOptionDataSource {
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

  void throwExceptionOnInvalidUserOption(List<String> options) {
    if (_yamlMapComputation != null) {
      for (final option in _yamlMap.keys) {
        if (!options.contains(option.toString())) {
          throw InvalidUserOptionException(option, "yaml file");
        }
      }
    }
  }

  T? _get<T>(UserOptionRegister userOptionsArgs) {
    for (final name in userOptionsArgs.names) {
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
  T? get<T>(UserOptionRegister userOptionsArgs, T Function(String text) transform) {
    final result = getString(userOptionsArgs);
    if (result == null) {
      return null;
    }
    return transform(result);
  }

  @override
  String? getString(UserOptionRegister userOptionsArgs) {
    return _get<String>(userOptionsArgs);
  }

  @override
  List<String>? getStringList(UserOptionRegister userOptionsArgs) {
    final result = _get<YamlList>(userOptionsArgs);
    if (result == null) {
      return null;
    }
    return result.toList(growable: false).whereType<String>().toList(growable: false);
  }

  @override
  bool? getBoolean(UserOptionRegister userOptionsArgs) {
    return _get<bool>(userOptionsArgs);
  }

  @override
  double? getDouble(UserOptionRegister userOptionsArgs) {
    final result = _get<Object>(userOptionsArgs);
    if (result is double) {
      return result;
    }
    if (result is int) {
      return result.toDouble();
    }

    return null;
  }

  @override
  int? getInt(UserOptionRegister userOptionsArgs) {
    final result = _get<Object>(userOptionsArgs);
    if (result is int) {
      return result;
    }
    if (result is double) {
      return result.toInt();
    }

    return null;
  }
}
