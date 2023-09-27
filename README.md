 ![image](https://github.com/songxing10000/flutter_sketchpad/assets/10040131/0005ab29-5f8d-42e1-8a20-4b53c0fb8819)


单指画线演算，双指上下左右拖动草稿纸；

画笔/橡皮擦/清空 
可输入json，点关闭时会回传画板上的json

 ```dart
_flutterSketchpadPlugin.showWithJsonString(_saveJsonString, (outputJsonString) {
  setState(() {
    _saveJsonString = outputJsonString;
  });
});
```
