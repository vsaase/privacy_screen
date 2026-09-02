#import "PrivacyScreenPlugin.h"
#if __has_include(<privacy_screen/privacy_screen-Swift.h>)
#import <privacy_screen/privacy_screen-Swift.h>
#else
#import "privacy_screen-Swift.h"
#endif

@implementation PrivacyScreenPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftPrivacyScreenPlugin registerWithRegistrar:registrar];
}
@end