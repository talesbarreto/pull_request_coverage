import 'package:pull_request_coverage/src/domain/user_options/user_options_args.dart';

abstract class UserOptionDataSource {
  String? getString(UserOptionsArgs userOptionsArgs);

  T? get<T>(UserOptionsArgs<T> userOptionsArgs, T Function(String text) transform);

  List<String>? getStringList(UserOptionsArgs<List<String>?> userOptionsArgs);

  bool? getBoolean(UserOptionsArgs<bool?> userOptionsArgs);

  int? getInt(UserOptionsArgs<int?> userOptionsArgs);

  double? getDouble(UserOptionsArgs<double?> userOptionsArgs);
}
