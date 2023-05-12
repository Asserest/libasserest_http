import 'dart:convert';

import 'package:async_task/async_task.dart';
import 'package:libasserest_interface/interface.dart';
import 'package:http/http.dart'
    hide get, patch, post, put, delete, head, read, readBytes, runWithClient;

import 'property.dart';

/// An [AsserestTestPlatform] for perform assertion on HTTP.
final class AsserestHttpTestPlatform
    extends AsserestTestPlatform<AsserestHttpProperty> {
  /// Determine keep request after redirectrd.
  ///
  /// This option is enabled by default.
  final bool handleRedirect;

  /// Construct a HTTP test platform for asserting with given [property]
  AsserestHttpTestPlatform(super.property,
      {super.counter, this.handleRedirect = true});

  Future<int> _makeRespWithStatus() {
    final Request req = Request(property.method.name, property.url)
      ..followRedirects = handleRedirect;

    req.headers.addAll(property.headers);

    assert(!property.method.bodyRequired || property.body != null);
    if (property.body != null) {
      req.body = (property.body is Map || property.body is List)
          ? jsonEncode(property.body)
          : property.body!.toString();
    }

    return Client().send(req).then((value) => value.statusCode);
  }

  @override
  AsyncTask<AsserestHttpProperty, AsserestReport> instantiate(
          AsserestHttpProperty parameters,
          [Map<String, SharedData>? sharedData]) =>
      AsserestHttpTestPlatform(property);

  @override
  AsserestHttpProperty parameters() => property;

  @override
  Future<AsserestResult> runTestProcess() async {
    try {
      // 300 for enabled handling redirection, 400 for not.
      final int httpErrCond = handleRedirect ? 300 : 400;

      if (property.accessible) {
        // Accessible
        for (int count = 0; count < property.tryCount!; count++) {
          int respCode = await _makeRespWithStatus();
          if (respCode < httpErrCond) {
            return AsserestResult.success;
          }
        }

        return AsserestResult.failure;
      } else {
        // Inaccessible
        return await _makeRespWithStatus() >= httpErrCond
            ? AsserestResult.success
            : AsserestResult.failure;
      }
    } on ClientException {
      return AsserestResult.failure;
    } catch (_) {
      return AsserestResult.error;
    }
  }
}
