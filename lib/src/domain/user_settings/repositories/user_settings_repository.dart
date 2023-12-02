import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_settings/models/user_settings.dart';

/// [UserSettingsRepository] parses the arguments passed to the application
abstract class UserSettingsRepository {
  Result<UserSettings> getUserSettings(List<String> arguments);
}
