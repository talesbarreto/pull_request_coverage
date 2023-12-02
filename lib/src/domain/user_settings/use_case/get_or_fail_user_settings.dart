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
    final userSettings = userSettingsRepository.getUserSettings(arguments);
    if (userSettings is ResultSuccess<UserSettings>) {
      return userSettings.data;
    } else {
      userSettings as ResultError<UserSettings>;
      final error = userSettings.error;
      if (error is UserSettingsException) {
        print(error.toString());
      } else {
        print("Error parsing params: ${userSettings.message}\n${userSettings.stackTrace}");
      }
      exit(ExitCode.error);
    }
  }
}
