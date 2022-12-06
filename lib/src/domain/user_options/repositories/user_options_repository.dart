import 'package:pull_request_coverage/src/domain/common/result.dart';
import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';

/// [UserOptionsRepository] parses the arguments passed to the application
abstract class UserOptionsRepository {
  Result<UserOptions> getUserOptions(List<String> arguments);
}
