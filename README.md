# HTTP accessibility assertion package for Asserest

One of the official Asserest tester package for asserting the given HTTP(S) is accessible.

## Configuration format

(Coming soon for schema descriptions)

## Mechanism

This assertion will cooperate with [http package](https://pub.dev/packages/http) and determine accessibily by getting responde code which ideally is `200` and vice versa without extracting body context of the response. In additions, it supports emulated request by defining header and body using JSON object, array or string which required for some request methods.

## Install

#### via commands

```bash
dart pub add libasserest_interface libasserest_http
```

#### via modifying `pubspec.yaml`

Open `pubspec.yaml` by editor and append two lines under `dependencies`:

```yaml
dependencies:
    # Please refer to latest release one
    libasserest_interface: ^1.0.0
    libasserest_http: ^1.0.0
```

Then, save it and run this command (if necessary):

```bash
dart pub get
```

## Licenses

AGPL-3.0 or later
