import 'package:pull_request_coverage/src/data/user_settings/data_source/settings_getters.dart';
import 'package:pull_request_coverage/src/data/user_settings/data_source/user_option_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_settings/user_settings_register.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

class _DataSource extends Fake implements UserSettingsDataSource {
  final String? result;

  _DataSource(this.result);

  @override
  int? getInt(UserSettingsRegister<int?> userOptionsArgs) => result != null ? int.tryParse(result!) : null;
}

void main() {
  group("when `getInt` is invoked", () {
    const userOptionsArgs = UserSettingsRegister(names: ['ha'], defaultValue: null);
    test("return result from the first data source when it is not null", () {
      final arg = SettingsGetters();
      arg.setDataSources([_DataSource("1"), _DataSource("2"), _DataSource("3")]);
      expect(arg.getInt(userOptionsArgs), 1);
    });

    test("return result from the second data source when the first one is null", () {
      final arg = SettingsGetters();
      arg.setDataSources([_DataSource(null), _DataSource("2"), _DataSource("3")]);
      expect(arg.getInt(userOptionsArgs), 2);
    });
  });
}
