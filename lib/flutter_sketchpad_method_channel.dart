import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'flutter_sketchpad_platform_interface.dart';

/// An implementation of [FlutterSketchpadPlatform] that uses method channels.
class MethodChannelFlutterSketchpad extends FlutterSketchpadPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sketchpad');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }


  @override
  Future<String?> showWithJsonString(String jsonString, DispearHandler dispearHandler) async {
    try {

      // 设置原生的callback得样用then？
      await methodChannel.invokeMethod('showWithJsonString', {'jsonString': jsonString}).then((result) {
        // 处理回调函数的结果
        if (dispearHandler != null) {
          dispearHandler(result);
        }
      }).catchError((error) {
        // 处理错误情况
      });

    } on PlatformException catch (e) {
      // 处理异常
      rethrow;
    }
  }
}
