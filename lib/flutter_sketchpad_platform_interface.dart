import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_sketchpad_method_channel.dart';
typedef void DispearHandler(String outputJsonString);

abstract class FlutterSketchpadPlatform extends PlatformInterface {
  /// Constructs a FlutterSketchpadPlatform.
  FlutterSketchpadPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSketchpadPlatform _instance = MethodChannelFlutterSketchpad();

  /// The default instance of [FlutterSketchpadPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSketchpad].
  static FlutterSketchpadPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterSketchpadPlatform] when
  /// they register themselves.
  static set instance(FlutterSketchpadPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    return _instance.getPlatformVersion();
  }
  Future<String?> showWithJsonString(String jsonString, DispearHandler dispearHandler) {
    return _instance.showWithJsonString(jsonString, dispearHandler);
  }



}
