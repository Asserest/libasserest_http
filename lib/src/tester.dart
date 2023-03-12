import 'dart:convert';

import 'package:async_task/async_task.dart';
import 'package:libasserest_interface/interface.dart';
import 'package:http/http.dart'
    hide get, patch, post, put, delete, head, read, readBytes, runWithClient;

import 'property.dart';

class AsserestHttpTestPlatform
    extends AsserestTestPlatform<AsserestHttpProperty> {
  final bool handleRedirect;

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
      return (await _makeRespWithStatus() < 400) ? AsserestResult.success : AsserestResult.failure;  
    } on ClientException {
      return AsserestResult.failure;
    } catch (_) {
      return AsserestResult.error;
    }
  }
}