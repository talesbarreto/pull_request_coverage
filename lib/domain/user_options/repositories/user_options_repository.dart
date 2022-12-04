import 'package:pull_request_coverage/domain/common/result.dart';
import 'package:pull_request_coverage/domain/user_options/models/user_options.dart';

abstract class UserOptionsRepository {
  Result<UserOptions> getUserOptions(List<String> arguments);
}
