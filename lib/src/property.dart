import 'dart:collection';
import 'dart:convert';

import 'package:libasserest_interface/interface.dart';
import 'package:meta/meta.dart';

import 'platform_iden/platform_iden.dart' as platform_iden;

const String _uaVersion = "1.x.x";

@sealed
class InvalidBodyTypeError extends TypeError implements AsserestError {
  final Type _bodyType;

  InvalidBodyTypeError._(this._bodyType);

  @override
  String toString() {
    StringBuffer buf = StringBuffer("InvalidBodyTypeError: ")
      ..write(message)
      ..writeln("Applied type: ")
      ..write(_bodyType);

    return buf.toString();
  }

  @override
  String get message =>
      "Body should be uses Map<String, dynamic>, List, String or leave it null.";
}

@sealed
class NonNullBodyRequiredException extends AsserestException {
  final HttpRequestMethod method;
  final dynamic _bodyContent;

  NonNullBodyRequiredException._(this.method, [this._bodyContent])
      : super("Body is mandatory for this method of HTTP request.");

  @override
  String toString() {
    StringBuffer buf = StringBuffer("NonNullBodyRequiredException: ")
      ..write(message)
      ..writeln("Applied method: ")
      ..write(method.name)
      ..writeln("Body required: ")
      ..write(method.bodyRequired ? "Yes" : "No");

    if (_bodyContent != null) {
      buf
        ..writeln("Body content: ")
        ..writeln((_bodyContent is Map || _bodyContent is List)
            ? jsonEncode(_bodyContent)
            : _bodyContent);
    }

    return buf.toString();
  }
}

enum HttpRequestMethod {
  GET(false),
  POST(true),
  PUT(true),
  DELETE(true),
  HEAD(false),
  PATCH(true);

  final bool bodyRequired;

  const HttpRequestMethod(this.bodyRequired);
}

class AsserestHttpProperty implements AsserestProperty {
  @override
  final Uri url;

  @override
  final bool accessible;

  @override
  final Duration timeout;

  @override
  final int? tryCount;

  final HttpRequestMethod method;

  final UnmodifiableMapView<String, String> headers;

  final Object? body;

  AsserestHttpProperty._(this.url, this.accessible, this.timeout, this.tryCount,
      this.method, this.headers, this.body) {
    if (body != null && body is! Map && body is! List && body is! String) {
      throw InvalidBodyTypeError._(body.runtimeType);
    } else if (method.bodyRequired && body == null) {
      throw NonNullBodyRequiredException._(method, body);
    }
  }
}

class HttpPropertyParseProcessor
    extends PropertyParseProcessor<AsserestHttpProperty> {
  const HttpPropertyParseProcessor();

  @override
  AsserestHttpProperty createProperty(
      Uri url,
      Duration timeout,
      bool accessible,
      int? tryCount,
      UnmodifiableMapView<String, dynamic> additionalProperty) {
    final HttpRequestMethod method = HttpRequestMethod.values
        .singleWhere((e) => e.name == additionalProperty["method"]);
    final Map<String, String>? headers = additionalProperty["header"];
    final Object? body = additionalProperty["body"];

    return AsserestHttpProperty._(
        url,
        accessible,
        timeout,
        tryCount,
        method,
        UnmodifiableMapView({
          "User-Agent":
              "Asserest $_uaVersion (${platform_iden.runtimePlatformInString})"
        }..addAll(headers ?? <String, String>{})),
        body);
  }

  @override
  Set<String> get supportedSchemes => const <String>{"http", "https"};
}
