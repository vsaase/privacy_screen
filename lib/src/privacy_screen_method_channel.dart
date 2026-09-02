import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '/src/privacy_helpers.dart';
import 'privacy_screen_platform_interface.dart';

/// An implementation of [PrivacyScreenPlatform] that uses method channels.
class MethodChannelPrivacyScreen extends PrivacyScreenPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('channel.couver.privacy_screen');

  @override
  Future<bool?> updateConfig({
    required PrivacyIosOptions iosOptions,
    required PrivacyAndroidOptions androidOptions,
    required Color backgroundColor,
    required PrivacyBlurEffect blurEffect,
  }) {
    final double backgroundOpacity = backgroundColor.a;
    final Color backgroundColorSolid = backgroundColor.withValues(alpha: 1);
    return methodChannel.invokeMethod<bool>(
      'updateConfig',
      {
        'iosLockWithDidEnterBackground':
            iosOptions.lockTrigger == IosLockTrigger.didEnterBackground,
        'privacyImageName': iosOptions.privacyImageName,
        'blurEffect': blurEffect.name,
        'backgroundColor':
            '#${backgroundColorSolid.toARGB32().toRadixString(16).substring(2, 8)}',
        'backgroundOpacity': backgroundOpacity,
        'enablePrivacyIos': iosOptions.enablePrivacy,
        'autoLockAfterSecondsIos': iosOptions.autoLockAfterSeconds,
        'enableSecureAndroid': androidOptions.enableSecure,
        'autoLockAfterSecondsAndroid': androidOptions.autoLockAfterSeconds,
      },
    );
  }
}
