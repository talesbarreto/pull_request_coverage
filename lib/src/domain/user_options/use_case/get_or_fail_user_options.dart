import 'dart:io';

import 'package:pull_request_coverage/src/domain/analyzer/models/exit_code.dart';
import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_option_exceptions.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/domain/user_options/repositories/user_options_repository.dart';

class GetOrFailUserOptions {
  final UserOptionsRepository userOptionsRepository;

  const GetOrFailUserOptions({required this.userOptionsRepository});

  UserOptions call(List<String> arguments) {
    final userOptions = userOptionsRepository.getUserOptions(arguments);
    if (userOptions is ResultSuccess<UserOptions>) {
      return userOptions.data;
    } else {
      userOptions as ResultError<UserOptions>;
      final error = userOptions.error;
      if (error is UserOptionException) {
        print(error.toString());
      } else {
        print("Error parsing params: ${userOptions.message}\n${userOptions.stackTrace}");
      }
      exit(ExitCode.error);
    }
  }
}
