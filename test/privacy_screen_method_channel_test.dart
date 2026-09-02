import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_screen/src/privacy_helpers.dart';
import 'package:privacy_screen/src/privacy_screen_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final MethodChannelPrivacyScreen platform = MethodChannelPrivacyScreen();

  test('sends the native configuration', () async {
    MethodCall? call;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, (methodCall) async {
      call = methodCall;
      return true;
    });

    final result = await platform.updateConfig(
      iosOptions: const PrivacyIosOptions(
        privacyImageName: 'PrivacyImage',
        autoLockAfterSeconds: 5,
      ),
      androidOptions: const PrivacyAndroidOptions(autoLockAfterSeconds: 10),
      backgroundColor: const Color(0x80402010),
      blurEffect: PrivacyBlurEffect.dark,
    );

    expect(result, isTrue);
    expect(call?.method, 'updateConfig');
    expect(call?.arguments, <String, Object?>{
      'iosLockWithDidEnterBackground': true,
      'privacyImageName': 'PrivacyImage',
      'blurEffect': 'dark',
      'backgroundColor': '#402010',
      'backgroundOpacity': closeTo(0.5, 0.01),
      'enablePrivacyIos': true,
      'autoLockAfterSecondsIos': 5,
      'enableSecureAndroid': true,
      'autoLockAfterSecondsAndroid': 10,
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.methodChannel, null);
  });
}
