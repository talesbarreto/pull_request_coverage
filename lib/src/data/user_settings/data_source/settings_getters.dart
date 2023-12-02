import 'package:pull_request_coverage/src/data/user_settings/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_settings/user_settings_register.dart';

class SettingsGetters implements UserSettingsDataSource {
  List<UserSettingsDataSource> sources = const [];

  /// [setDataSources] sets a set of data sources sorted by priority: on each getter, the first source
  /// wil be used and, if null, [SettingsGetters] will try the next one and so on
  void setDataSources(List<UserSettingsDataSource> sources) => this.sources = sources;

  T? _tryGetOnEachSource<T>(T? Function(UserSettingsDataSource source) on) {
    for (final source in sources) {
      final result = on(source);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  @override
  T? get<T>(UserSettingsRegister<T> userSettingArgs, T Function(String text) transform) {
    return _tryGetOnEachSource((source) => source.get(userSettingArgs, transform));
  }

  @override
  String? getString(UserSettingsRegister userSettingArgs) {
    return _tryGetOnEachSource((source) => source.getString(userSettingArgs));
  }

  @override
  List<String>? getStringList(UserSettingsRegister<List<String>?> userSettingArgs) {
    return _tryGetOnEachSource((source) => source.getStringList(userSettingArgs));
  }

  @override
  double? getDouble(UserSettingsRegister<double?> userSettingArgs) {
    return _tryGetOnEachSource((source) => source.getDouble(userSettingArgs));
  }

  @override
  int? getInt(UserSettingsRegister<int?> userSettingArgs) {
    return _tryGetOnEachSource((source) => source.getInt(userSettingArgs));
  }

  @override
  bool? getBoolean(UserSettingsRegister<bool?> userSettingArgs) {
    return _tryGetOnEachSource((source) => source.getBoolean(userSettingArgs));
  }

  bool getBooleanOrDefault(UserSettingsRegister<bool> userSettingArgs) {
    return getBoolean(userSettingArgs) ?? userSettingArgs.defaultValue;
  }
}
