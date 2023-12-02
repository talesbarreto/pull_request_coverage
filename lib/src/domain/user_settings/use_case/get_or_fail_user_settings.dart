import 'dart:io';

import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings_exceptions.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';
import 'package:pull_request_coverage/src/domain/user_settings/repositories/user_settings_repository.dart';

class GetOrFailUserSettings {
  final UserSettingsRepository userSettingsRepository;

  const GetOrFailUserSettings({required this.userSettingsRepository});

  UserSettings call(List<String> arguments) {
    final userOptions = userSettingsRepository.getUserSettings(arguments);
    if (userOptions is ResultSuccess<UserSettings>) {
      return userOptions.data;
    } else {
      userOptions as ResultError<UserSettings>;
      final error = userOptions.error;
      if (error is UserSettingsException) {
        print(error.toString());
      } else {
        print("Error parsing params: ${userOptions.message}\n${userOptions.stackTrace}");
      }
      exit(ExitCode.error);
    }
  }
}
