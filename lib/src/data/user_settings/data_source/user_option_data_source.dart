import 'package:pull_request_coverage/src/domain/user_settings/user_settings_register.dart';

abstract class UserSettingsDataSource {
  String? getString(UserSettingsRegister userSettingArgs);

  T? get<T>(UserSettingsRegister<T> userSettingArgs, T Function(String text) transform);

  List<String>? getStringList(UserSettingsRegister<List<String>?> userSettingArgs);

  bool? getBoolean(UserSettingsRegister<bool?> userSettingArgs);

  int? getInt(UserSettingsRegister<int?> userSettingArgs);

  double? getDouble(UserSettingsRegister<double?> userSettingArgs);
}
