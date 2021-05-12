#import "FlutterAarPlugin.h"
#if __has_include(<flutter_aar/flutter_aar-Swift.h>)
#import <flutter_aar/flutter_aar-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_aar-Swift.h"
#endif

@implementation FlutterAarPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAarPlugin registerWithRegistrar:registrar];
}
@end
