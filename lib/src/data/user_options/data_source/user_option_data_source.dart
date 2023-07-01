import 'package:pull_request_coverage/src/domain/user_options/user_option_register.dart';

abstract class UserOptionDataSource {
  String? getString(UserOptionRegister userOptionsArgs);

  T? get<T>(UserOptionRegister<T> userOptionsArgs, T Function(String text) transform);

  List<String>? getStringList(UserOptionRegister<List<String>?> userOptionsArgs);

  bool? getBoolean(UserOptionRegister<bool?> userOptionsArgs);

  int? getInt(UserOptionRegister<int?> userOptionsArgs);

  double? getDouble(UserOptionRegister<double?> userOptionsArgs);
}
