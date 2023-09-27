#import "FlutterSketchpadPlugin.h"
#import "MWSSketchpadView.h"
@implementation FlutterSketchpadPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_sketchpad"
                                     binaryMessenger:[registrar messenger]];
    FlutterSketchpadPlugin* instance = [[FlutterSketchpadPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
     else if ([@"showWithJsonString" isEqualToString:call.method]) {
        
 
            NSString *jsonString = call.arguments[@"jsonString"];

            MWSSketchpadView *sketchpadView = [MWSSketchpadView shareInstance];
              [sketchpadView showWithJsonString:jsonString dispearHandler:^(NSString *outputJsonstring) {
                // 回调函数
                result(outputJsonstring);
              }];
         
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}
 
@end
