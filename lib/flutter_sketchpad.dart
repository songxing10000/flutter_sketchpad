
import 'flutter_sketchpad_platform_interface.dart';

class FlutterSketchpad {
  Future<String?> getPlatformVersion() {
    return FlutterSketchpadPlatform.instance.getPlatformVersion();
  }
  Future<String?> showWithJsonString(String jsonString, DispearHandler dispearHandler) {
    return FlutterSketchpadPlatform.instance.showWithJsonString(jsonString, dispearHandler);
  }

}
