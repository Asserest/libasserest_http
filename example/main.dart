import 'package:libasserest_interface/interface.dart';
import 'package:libasserest_http/http.dart';
import 'package:libasserest_http/initializer.dart';

void main() {
  asserestHttpSetup();

  final List<AsserestHttpProperty> httpProp = [
    AsserestHttpProperty(Uri.https("www.example.com"), true,
        Duration(seconds: 30), 5, HttpRequestMethod.GET, null, null),
    AsserestHttpProperty(Uri.https("www.foo.com"), false, Duration(seconds: 30),
        null, HttpRequestMethod.POST, null, "Sample text")
  ];

  final executor = httpProp.assignAndBuildExecutor(
      name: "Sample HTTP assertion", threads: 2);

  void shutdownExecutor() async {
    executor.shutdown();
  }

  executor.invoke().listen((report) {
    print(report.actual);
  })
    ..onDone(shutdownExecutor)
    // ignore: argument_type_not_assignable_to_error_handler
    ..onError(shutdownExecutor);
}
