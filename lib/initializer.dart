/// An initializer library for guiding setup process with [asserestHttpSetup].
///
/// This should be imported under the entry point of the program (`main()`) with
/// http file:
///
/// **Dart console program**
/// ```dart
/// import 'package:libasserest_interface/interface.dart';
/// import 'package:libasserest_http/http.dart'; // HTTP implementation of Asserest
/// // Initializer only, does not contains all exported content from above.
/// import 'package:libasserest_http/initializer.dart';
///
/// void main(List<String> args) {
///   asserestHttpSetup();
///   // Implementation below
/// }
/// ```
///
/// **Flutter**
/// ```dart
/// import 'package:flutter/material.dart';
///
/// import 'package:libasserest_interface/interface.dart';
/// import 'package:libasserest_http/http.dart'; // HTTP implementation of Asserest
/// // Initializer only, does not contains all exported content from above.
/// import 'package:libasserest_http/initializer.dart';
///
/// void main() {
///   asserestHttpSetup(); // It's OK to be put without Widget binding.
///
///   WidgetFlutterBinding.ensureInitialized();
///   // Any code that required to do after widget binded.
///   runApp(const App());
/// }
/// ```
library initializer;

import 'package:libasserest_interface/interface.dart';
import 'src/property.dart'
    show AsserestHttpProperty, HttpPropertyParseProcessor;
import 'src/tester.dart';

/// Guard check to prevent [asserestHttpSetup] called more than once.
bool _asserestHttpSetup = false;

/// Quick setup method for automatically binding [HttpPropertyParseProcessor]
/// and [AsserestHttpTestPlatform] into [AsserestPropertyParser] and
/// [AsserestTestAssigner] respectively.
///
/// This method must be callel at **ONCE** only, calling multiple time will
/// throw [StateError] to prevent duplicated input, even though you have been
/// removed those [PropertyParseProcessor] and [AsserestTestPlatform] already.
void asserestHttpSetup({bool counter = false, bool handleRedirect = true}) {
  if (_asserestHttpSetup) {
    throw StateError(
        "This method should be call once only. If you removed property parse processor or test platform, please add them manually.");
  }

  _asserestHttpSetup = true;
  AsserestPropertyParser().define(HttpPropertyParseProcessor());
  AsserestTestAssigner().assign(
      AsserestHttpProperty,
      (property) => AsserestHttpTestPlatform(property as AsserestHttpProperty,
          counter: counter, handleRedirect: handleRedirect));
}
