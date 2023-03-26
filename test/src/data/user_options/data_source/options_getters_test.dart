import 'package:pull_request_coverage/src/data/user_options/data_source/options_getters.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_options_args.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class _DataSource extends Fake implements UserOptionDataSource {
  final String? result;

  _DataSource(this.result);

  @override
  int? getInt(UserOptionsArgs<int?> userOptionsArgs) => result != null ? int.tryParse(result!) : null;
}

void main() {
  group("when `getInt` is invoked", () {
    const userOptionsArgs = UserOptionsArgs(name: 'ha', defaultValue: null);
    test("return result from the first data source when it is not null", () {
      final arg = OptionsGetters();
      arg.setDataSources([_DataSource("1"), _DataSource("2"), _DataSource("3")]);
      expect(arg.getInt(userOptionsArgs), 1);
    });

    test("return result from the second data source when the first one is null", () {
      final arg = OptionsGetters();
      arg.setDataSources([_DataSource(null), _DataSource("2"), _DataSource("3")]);
      expect(arg.getInt(userOptionsArgs), 2);
    });
  });
}
