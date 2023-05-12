/// To identify runtime platform as a part from default `User-Agent` value.
///
/// For running under web platform, it just returned a [String] from
/// `windows.navigator.userAgent`. For runnning under Dart VM, the
/// format will become `Dart VM (Platform.version)`.
///
/// When the runtime is neither on web nor VM, it just return `---Unknown platform---`.
String get runtimePlatformInString => "---Unknown platform---";
