import 'package:args/args.dart';
import 'package:pull_request_coverage/src/data/user_options/data_source/arg_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_options_args.dart';
import 'package:test/test.dart';

void main() {
  const option = UserOptionsArgs(names: ["option", "alias"], defaultValue: null);

  ArgDataSource getDataSource() {
    return ArgDataSource(ArgParser(), [option]);
  }

  test("parse Int type correctly", () {
    final dataSource = getDataSource();
    dataSource.parse(["--${option.names.first}", "3"]);
    expect(dataSource.getInt(option), 3);
  });

  group("parse Double type correctly", () {
    test("when it is a double", () {
      final dataSource = getDataSource();
      dataSource.parse(["--${option.names.last}", "3.6"]);
      expect(dataSource.getDouble(option), 3.6);
    });
    test("when it is, actually, an int", () {
      final dataSource = getDataSource();
      dataSource.parse(["--${option.names.first}", "3"]);
      expect(dataSource.getDouble(option), 3);
    });
  });

  test("parse String type correctly", () {
    final dataSource = getDataSource();
    dataSource.parse(["--${option.names.last}", "alabama"]);
    expect(dataSource.getString(option), "alabama");
  });

  test("parse Boolean type correctly", () {
    final dataSource = getDataSource();
    dataSource.parse(["--${option.names.first}", "true"]);
    expect(dataSource.getBoolean(option), true);
  });

  test("parse String List type correctly", () {
    final dataSource = getDataSource();
    dataSource.parse(["--${option.names.last}", "*ha,he,hi,ho,hu"]);
    expect(dataSource.getStringList(option), ["*ha", "he", "hi", "ho", "hu"]);
  });
}
