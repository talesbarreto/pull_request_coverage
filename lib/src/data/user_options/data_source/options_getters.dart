import 'package:pull_request_coverage/src/data/user_options/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_option_register.dart';

class OptionsGetters implements UserOptionDataSource {
  List<UserOptionDataSource> sources = const [];

  /// [setDataSources] sets a set of data sources sorted by priority: on each getter, the first source
  /// wil be used and, if null, [OptionsGetters] will try the next one and so on
  void setDataSources(List<UserOptionDataSource> sources) => this.sources = sources;

  T? _tryGetOnEachSource<T>(T? Function(UserOptionDataSource source) on) {
    for (final source in sources) {
      final result = on(source);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  @override
  T? get<T>(UserOptionRegister<T> userOptionsArgs, T Function(String text) transform) {
    return _tryGetOnEachSource((source) => source.get(userOptionsArgs, transform));
  }

  @override
  String? getString(UserOptionRegister userOptionsArgs) {
    return _tryGetOnEachSource((source) => source.getString(userOptionsArgs));
  }

  @override
  List<String>? getStringList(UserOptionRegister<List<String>?> userOptionsArgs) {
    return _tryGetOnEachSource((source) => source.getStringList(userOptionsArgs));
  }

  @override
  double? getDouble(UserOptionRegister<double?> userOptionsArgs) {
    return _tryGetOnEachSource((source) => source.getDouble(userOptionsArgs));
  }

  @override
  int? getInt(UserOptionRegister<int?> userOptionsArgs) {
    return _tryGetOnEachSource((source) => source.getInt(userOptionsArgs));
  }

  @override
  bool? getBoolean(UserOptionRegister<bool?> userOptionsArgs) {
    return _tryGetOnEachSource((source) => source.getBoolean(userOptionsArgs));
  }

  bool getBooleanOrDefault(UserOptionRegister<bool> userOptionsArgs) {
    return getBoolean(userOptionsArgs) ?? userOptionsArgs.defaultValue;
  }
}
