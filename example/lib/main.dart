import 'package:flutter/material.dart';
import 'package:privacy_screen/privacy_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: (_, child) {
        return PrivacyGate(
          lockBuilder: (ctx) => const LockerPage(),
          navigatorKey: navigatorKey,
          onLifeCycleChanged: (_) {},
          onLock: () {},
          onUnlock: () {},
          child: child,
        );
      },
      home: const FirstRoute(),
    );
  }
}

class FirstRoute extends StatefulWidget {
  const FirstRoute({super.key});

  @override
  State<FirstRoute> createState() => _FirstRouteState();
}

class _FirstRouteState extends State<FirstRoute> {
  List<String> lifeCycleHistory = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        launchUrl(Uri.parse("https://www.flutter.dev/")),
                    child: const Text("Test Native: Url Launch"),
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () async {
                      await PrivacyScreen.instance.enable(
                        iosOptions: const PrivacyIosOptions(
                          enablePrivacy: true,
                          privacyImageName: "LaunchImage",
                          autoLockAfterSeconds: 5,
                          lockTrigger: IosLockTrigger.didEnterBackground,
                        ),
                        androidOptions: const PrivacyAndroidOptions(
                          enableSecure: true,
                          autoLockAfterSeconds: 5,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0),
                        blurEffect: PrivacyBlurEffect.extraLight,
                      );
                    },
                    child: const Text("Enable extraLight"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await PrivacyScreen.instance.enable(
                        iosOptions: const PrivacyIosOptions(
                          enablePrivacy: true,
                          privacyImageName: "LaunchImage",
                          autoLockAfterSeconds: 5,
                          lockTrigger: IosLockTrigger.didEnterBackground,
                        ),
                        androidOptions: const PrivacyAndroidOptions(
                          enableSecure: true,
                          autoLockAfterSeconds: 5,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0),
                        blurEffect: PrivacyBlurEffect.light,
                      );
                    },
                    child: const Text("Enable light"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await PrivacyScreen.instance.enable(
                        iosOptions: const PrivacyIosOptions(
                          enablePrivacy: true,
                          privacyImageName: "LaunchImage",
                          autoLockAfterSeconds: 5,
                          lockTrigger: IosLockTrigger.didEnterBackground,
                        ),
                        androidOptions: const PrivacyAndroidOptions(
                          enableSecure: true,
                          autoLockAfterSeconds: 5,
                        ),
                        backgroundColor: Colors.red.withValues(alpha: 0.4),
                        blurEffect: PrivacyBlurEffect.dark,
                      );
                    },
                    child: const Text("Enable dark"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await PrivacyScreen.instance.disable();
                    },
                    child: const Text("Disable"),
                  ),
                  const Divider(),
                  ElevatedButton(
                    onPressed: () {
                      PrivacyScreen.instance.lock();
                    },
                    child: const Text("Lock"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      PrivacyScreen.instance.pauseLock();
                    },
                    child: const Text("Pause Auto Lock"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      PrivacyScreen.instance.pauseLock();
                    },
                    child: const Text("Resume Auto Lock"),
                  ),
                  const Divider(),
                  ...lifeCycleHistory.map((e) => Text(e)).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LockerPage extends StatelessWidget {
  const LockerPage({super.key});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        var result = await showDialog(
          context: context,
          builder: (ctx) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Confirmation",
                    style: TextStyle(fontSize: 24),
                  ),
                  const Text("Are you sure to unlock?"),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes'),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('No'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (result == true) {
          PrivacyScreen.instance.unlock();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(),
              ElevatedButton(
                child: const Text("Unlock"),
                onPressed: () => PrivacyScreen.instance.unlock(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
