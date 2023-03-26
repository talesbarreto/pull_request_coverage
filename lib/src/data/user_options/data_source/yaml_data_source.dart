import 'package:pull_request_coverage/src/data/user_options/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_options_args.dart';
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

  @override
  T? get<T>(UserOptionsArgs userOptionsArgs, T Function(String text) transform) {
    final result = getString(userOptionsArgs);
    if (result == null) {
      return null;
    }
    return transform(result);
  }

  @override
  String? getString(UserOptionsArgs userOptionsArgs) {
    return _yamlMap[userOptionsArgs.name];
  }

  @override
  List<String>? getStringList(UserOptionsArgs userOptionsArgs) {
    final result = _yamlMap[userOptionsArgs.name];
    if (result == null) {
      return null;
    }
    if (result is YamlList) {
      return result.toList(growable: false).whereType<String>().toList(growable: false);
    }
    throw Exception("Fail to parse yaml ${userOptionsArgs.name}: $result");
  }

  @override
  bool? getBoolean(UserOptionsArgs userOptionsArgs) {
    return _yamlMap[userOptionsArgs.name];
  }

  @override
  double? getDouble(UserOptionsArgs userOptionsArgs) {
    final result = _yamlMap[userOptionsArgs.name];
    if (result is int) {
      return result.toDouble();
    }
    return _yamlMap[userOptionsArgs.name];
  }

  @override
  int? getInt(UserOptionsArgs userOptionsArgs) {
    final result = _yamlMap[userOptionsArgs.name];
    if (result is double) {
      return result.toInt();
    }
    return _yamlMap[userOptionsArgs.name];
  }
}
