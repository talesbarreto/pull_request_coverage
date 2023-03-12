import 'package:pull_request_coverage/src/domain/user_options/models/user_options.dart';
import 'package:pull_request_coverage/src/presentation/use_case/colorize_cli_text.dart';

class PrintDeprecatedArgsWarning {
  final void Function(String message) print;
  final ColorizeCliText colorizeText;

  const PrintDeprecatedArgsWarning(this.print, this.colorizeText);

  void call(UserOptions userOptions) {
    if (userOptions.deprecatedFilterSet) {
      print(colorizeText(
        r'''
        [WARNING] `exclude-prefix` and `exclude-suffix` args are now deprecated. (but still works ;-)
                  use `exclude` instead. It receive a list of Glob syntaxt, closely to the widely-known Bash glob syntax: 
                  https://pub.dev/packages/glob#syntax, so:
                       - replace `--exclude-prefix `bla,ble` by `--exclude 'bla**',ble**'
                       - replace `--exclude-suffix `bla,ble` by `--exclude '**bla',**ble'
        
                  `exclude-suffix` no longer has a default values with generated files pattern. 
                  Now, there is `exclude-known-generated-files` that defaults to true.
        ''',
        TextColor.yellow,
      ));
    }
  }
}
