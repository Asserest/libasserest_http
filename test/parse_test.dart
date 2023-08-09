import 'package:libasserest_http/initializer.dart';
import 'package:libasserest_http/src/property.dart';
import 'package:libasserest_interface/interface.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    asserestHttpSetup();
  });
  test("Parse from Map test", () {
    AsserestHttpProperty httpProp = AsserestPropertyParser().parse({
      "url": "https://example.com",
      "accessible": true,
      "timeout": 10,
      "try_count": 3,
      "method": "GET"
    }) as AsserestHttpProperty;

    expect(httpProp.url.toString(), equalsIgnoringCase("https://example.com"));
    expect(httpProp.accessible, isTrue);
    expect(httpProp.timeout, equals(Duration(seconds: 10)));
    expect(httpProp.tryCount, isNotNull);
    expect(httpProp.method, equals(HttpRequestMethod.GET));
  });
  test("Invalid parse", () {
    expect(() => AsserestPropertyParser().parse({
      "url": "https://sampletext.com",
      "accessible": false,
      "try_count": 3,
      "method": "GET"
    }), throwsA(isA<InvalidPropertyMapException>()));
    expect(() => AsserestPropertyParser().parse({
      "url": "https://foo.com",
      "accessible": true,
      "method": "POST"
    }), throwsA(isA<NonNullBodyRequiredException>()));
  });
}