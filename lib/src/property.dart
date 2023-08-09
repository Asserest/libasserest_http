import 'dart:collection';
import 'dart:convert';

import 'package:libasserest_interface/interface.dart';

import 'platform_iden/platform_iden.dart' as platform_iden;

/// Asserest version for User-Agent
const String _uaVersion = "1.x.x";

/// [TypeError] based [AsserestError] when the given [AsserestHttpProperty.body]
/// does not stastified these [Type]:
///
/// * [Map]
/// * [List]
/// * [String]
/// * [Null]
final class InvalidBodyTypeError extends TypeError implements AsserestError {
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

/// An [AsserestException] for detect the given [HttpRequestMethod] is required
/// body content to make request.
final class NonNullBodyRequiredException extends AsserestException {
  /// An method uses that required[HttpRequestMethod.bodyRequired]
  final HttpRequestMethod method;
  final dynamic _bodyContent;

  NonNullBodyRequiredException._(this.method, [this._bodyContent])
      : assert(method.bodyRequired, "Raise body required if requried actually"),
        super("Body is mandatory for this method of HTTP request.");

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

/// Enumerated value for indicating [HttpRequestMethod].
enum HttpRequestMethod {
  /// Make `'GET'` request.
  ///
  /// It is one of the only two methods that allows to make request
  /// without apply body content.
  GET(false),

  /// Make `'POST'` request.
  POST(true),

  /// Make `'PUT'` request.
  PUT(true),

  /// Make `'DELETE'` request.
  DELETE(true),

  /// Make `'HEAD'` request.
  ///
  /// It is one of the only two methods that allows to make request
  /// without apply body content.
  HEAD(false),

  /// Make `'PATCH'` request.
  PATCH(true);

  /// Determine the body content is mandatory for given request method.
  final bool bodyRequired;

  /// Initialize method value with [bodyRequired].
  const HttpRequestMethod(this.bodyRequired);
}

/// An [AsserestProperty] to specify the following test in HTTP.
final class AsserestHttpProperty implements AsserestProperty {
  @override
  final Uri url;

  @override
  final bool accessible;

  @override
  final Duration timeout;

  @override
  final int? tryCount;

  /// Method uses for making request and asserting HTTP response.
  final HttpRequestMethod method;

  /// Header of the request.
  ///
  /// By default, it contains default `User-Agent` if no further specified.
  final UnmodifiableMapView<String, String> headers;

  /// Body content of the following request.
  ///
  /// The [body] type can be [Map], [List], [String] and leave it as [Null]
  /// if the given [method] is allowed.
  ///
  /// It throws [InvalidBodyTypeError] if [body] is not in the mentioned type or
  /// [NonNullBodyRequiredException] if body content becomes mandatory for
  /// [method].
  final Object? body;

  AsserestHttpProperty(this.url, this.accessible, this.timeout, this.tryCount,
      this.method, Map<String, String>? headers, this.body)
      : this.headers =
            UnmodifiableMapView(headers ?? const <String, String>{}) {
    if (body != null && body is! Map && body is! List && body is! String) {
      throw InvalidBodyTypeError._(body.runtimeType);
    } else if (method.bodyRequired && body == null) {
      throw NonNullBodyRequiredException._(method, body);
    }
  }
}

/// [PropertyParseProcessor] for handling [AsserestHttpProperty].
final class HttpPropertyParseProcessor
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

    return AsserestHttpProperty(
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
