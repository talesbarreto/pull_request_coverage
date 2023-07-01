import 'package:pull_request_coverage/src/data/user_options/data_source/yaml_data_source.dart';
import 'package:pull_request_coverage/src/domain/user_options/user_option_register.dart';
import 'package:test/test.dart';

void main() {
  const option = UserOptionRegister(names: ["option", "alias"], defaultValue: null);

  test("parse Int type correctly", () {
    final dataSource = YamlDataSource();
    dataSource.parse("${option.names.first} : 3");
    expect(dataSource.getInt(option), 3);
  });

  group("parse Double type correctly", () {
    test("when it is a double", () {
      final dataSource = YamlDataSource();
      dataSource.parse("${option.names.first} : 3.6");
      expect(dataSource.getDouble(option), 3.6);
    });
    test("when it is, actually, an int", () {
      final dataSource = YamlDataSource();
      dataSource.parse("${option.names.last} : 3");
      expect(dataSource.getDouble(option), 3);
    });
  });

  group("parse String type correctly", () {
    test("when it has quote symbol", () {
      final dataSource = YamlDataSource();
      dataSource.parse("${option.names.first} : \"alabama\"");
      expect(dataSource.getString(option), "alabama");
    });
    test("when it has no quote symbol", () {
      final dataSource = YamlDataSource();
      dataSource.parse("${option.names.last} : alabama");
      expect(dataSource.getString(option), "alabama");
    });
  });

  test("parse Boolean type correctly", () {
    final dataSource = YamlDataSource();
    dataSource.parse("${option.names.first} : true");
    expect(dataSource.getBoolean(option), true);
  });

  test("parse String List type correctly", () {
    final dataSource = YamlDataSource();
    dataSource.parse("${option.names.first}:\n- ha\n- he\n- hi\n- ho\n- hu");
    expect(dataSource.getStringList(option), ["ha", "he", "hi", "ho", "hu"]);
  });
}
