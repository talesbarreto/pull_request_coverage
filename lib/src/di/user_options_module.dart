import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/arg_data_source.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/options_getters.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/yaml_data_source.dart';
import 'package:pull_request_coverage/src/data/user_options/user_options_repository_impl.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';
import 'package:pull_request_coverage/src/domain/user_options/use_case/get_or_fail_user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_option_register.dart';

class UserOptionsModule {
  const UserOptionsModule._();

  static UserOptions provideUserOptions({
    required List<String> arguments,
    required FileSystem fileSystem,
  }) {
    return GetOrFailUserOptions(
      userOptionsRepository: provideUserOptionsRepository(fileSystem: fileSystem),
    ).call(arguments);
  }

  static UserOptionsRepository provideUserOptionsRepository({
    required FileSystem fileSystem,
  }) {
    return UserOptionsRepositoryImpl(
      argDataSource: ArgDataSource(ArgParser(), UserOptionRegister.options),
      yamlDataSource: YamlDataSource(),
      argGetters: OptionsGetters(),
      fileSystem: fileSystem,
    );
  }
}
