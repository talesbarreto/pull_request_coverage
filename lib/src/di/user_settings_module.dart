import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:pull_request_coverage/src/data/user_settings/data_source/arg_data_source.dart';
import 'package:pull_request_coverage/src/data/user_settings/data_source/settings_getters.dart';
import 'package:pull_request_coverage/src/data/user_settings/data_source/yaml_data_source.dart';
import 'package:pull_request_coverage/src/data/user_settings/user_settings_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/user_settings/repositories/user_settings_repository.dart';
import 'package:pull_request_coverage/src/domain/user_settings/use_case/get_or_fail_user_settings.dart';
import 'package:pull_request_coverage/src/domain/user_settings/user_settings_register.dart';

class UserSettingsModule {
  const UserSettingsModule._();

  static GetOrFailUserSettings provideGetOrFailUserSettings({
    required FileSystem fileSystem,
  }) {
    return GetOrFailUserSettings(
      userSettingsRepository: provideUserSettingsRepository(
        fileSystem: fileSystem,
      ),
    );
  }

  static UserSettingsRepository provideUserSettingsRepository({
    required FileSystem fileSystem,
  }) {
    return UserSettingsRepositoryImpl(
      argDataSource: ArgDataSource(ArgParser(), UserSettingsRegister.options),
      yamlDataSource: YamlDataSource(),
      argGetters: SettingsGetters(),
      fileSystem: fileSystem,
    );
  }
}
