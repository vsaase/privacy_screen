import Flutter
import UIKit

public class SwiftPrivacyScreenPlugin: NSObject, FlutterPlugin {
  var enablePrivacy = false
  var lockWithDidEnterBackground = true
  var privacyImageName: String?
  var backgroundOpacity: CGFloat = 1
  var backgroundColor = UIColor.white
  var backgroundTask: UIBackgroundTaskIdentifier!
  var privacyUIView: UIView?
  var isInFadeIn = false
  let animationDuration: CFTimeInterval = 0.2
  var methodChannel: FlutterMethodChannel
  var timeEnteredBackground: Double = 0
  var autoLockAfterSeconds: Double = -1
  var blurEffect: UIBlurEffect.Style?
  var lockedDismissDelay: CFTimeInterval = 0.2
  private var lifecycleObservers: [NSObjectProtocol] = []

  internal let registrar: FlutterPluginRegistrar

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    methodChannel = FlutterMethodChannel(
      name: "channel.couver.privacy_screen", binaryMessenger: registrar.messenger())
    super.init()
    registerSceneLifecycleObservers()
  }

  deinit {
    for observer in lifecycleObservers {
      NotificationCenter.default.removeObserver(observer)
    }
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftPrivacyScreenPlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: instance.methodChannel)
  }

  private func createPrivacyView() {
    if let window = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)
    {
      dismissPrivacyView()
      privacyUIView = UIView(frame: window.bounds)
      privacyUIView?.alpha = 0.0
      window.addSubview(privacyUIView!)

      if let blurEffect, backgroundOpacity < 1 {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        blurView.frame = window.bounds
        privacyUIView!.addSubview(blurView)
      }
      if backgroundOpacity > 0 {
        let opacityView = UIView(frame: window.bounds)
        opacityView.backgroundColor = backgroundColor
        opacityView.alpha = backgroundOpacity
        privacyUIView!.addSubview(opacityView)
      }
      if let privacyImageName, !privacyImageName.isEmpty {
        let logoView = UIImageView(image: UIImage(named: privacyImageName))
        logoView.frame = window.bounds
        logoView.contentMode = .center
        privacyUIView!.addSubview(logoView)
      }

      isInFadeIn = true
      privacyUIView?.layer.removeAllAnimations()
      UIView.transition(
        with: privacyUIView!, duration: animationDuration, options: .transitionCrossDissolve,
        animations: {
          self.privacyUIView?.alpha = 1.0
          self.isInFadeIn = false
          window.snapshotView(afterScreenUpdates: true)
        })
    }
  }

  private func dismissPrivacyView() {
    guard privacyUIView != nil else { return }
    privacyUIView?.layer.removeAllAnimations()
    UIView.transition(
      with: privacyUIView!, duration: animationDuration, options: .transitionCrossDissolve,
      animations: { self.privacyUIView?.alpha = 0.0 }
    ) { finished in
      if finished && self.privacyUIView != nil && self.isInFadeIn {
        for subview in self.privacyUIView!.subviews { subview.removeFromSuperview() }
        self.privacyUIView?.removeFromSuperview()
        self.privacyUIView = nil
      }
    }
  }

  private func judgeLock() {
    let nowTime = NSDate().timeIntervalSince1970
    if autoLockAfterSeconds >= 0 && timeEnteredBackground > 0
      && nowTime - timeEnteredBackground > autoLockAfterSeconds
    {
      methodChannel.invokeMethod("lock", arguments: nil)
      DispatchQueue.main.asyncAfter(deadline: .now() + lockedDismissDelay) {
        self.dismissPrivacyView()
      }
    } else {
      dismissPrivacyView()
    }
    timeEnteredBackground = 0
  }

  private func registerSceneLifecycleObservers() {
    let notificationCenter = NotificationCenter.default
    lifecycleObservers = [
      notificationCenter.addObserver(
        forName: UIScene.didActivateNotification, object: nil, queue: .main
      ) { [weak self] _ in
        self?.sceneDidBecomeActive()
      },
      notificationCenter.addObserver(
        forName: UIScene.didEnterBackgroundNotification, object: nil, queue: .main
      ) { [weak self] _ in
        self?.sceneDidEnterBackground()
      },
      notificationCenter.addObserver(
        forName: UIScene.willEnterForegroundNotification, object: nil, queue: .main
      ) { [weak self] _ in
        self?.sceneWillEnterForeground()
      },
      notificationCenter.addObserver(
        forName: UIScene.willDeactivateNotification, object: nil, queue: .main
      ) { [weak self] _ in
        self?.sceneWillResignActive()
      },
    ]
  }

  private func sceneDidBecomeActive() {
    methodChannel.invokeMethod("onLifeCycle", arguments: "applicationDidBecomeActive")
    judgeLock()
  }

  private func sceneDidEnterBackground() {
    if lockWithDidEnterBackground { timeEnteredBackground = NSDate().timeIntervalSince1970 }
    methodChannel.invokeMethod("onLifeCycle", arguments: "applicationDidEnterBackground")
  }

  private func sceneWillEnterForeground() {
    methodChannel.invokeMethod("onLifeCycle", arguments: "applicationWillEnterForeground")
  }

  private func sceneWillResignActive() {
    if !lockWithDidEnterBackground { timeEnteredBackground = NSDate().timeIntervalSince1970 }
    methodChannel.invokeMethod("onLifeCycle", arguments: "applicationWillResignActive")
    if enablePrivacy {
      registerBackgroundTask()
      UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
      createPrivacyView()
      endBackgroundTask()
    }
  }

  func registerBackgroundTask() {
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }
    assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
  }

  func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = UIBackgroundTaskIdentifier.invalid
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "updateConfig" else {
      result(FlutterMethodNotImplemented)
      return
    }
    let args = call.arguments as? [String: Any]
    backgroundOpacity = args?["backgroundOpacity"] as? CGFloat ?? 1
    privacyImageName = args?["privacyImageName"] as? String
    if let backgroundColor = args?["backgroundColor"] as? String {
      self.backgroundColor = hexStringToUIColor(hex: backgroundColor)
    } else {
      backgroundColor = .white
    }
    if let blurEffect = args?["blurEffect"] as? String {
      switch blurEffect {
      case "light": self.blurEffect = .light
      case "dark": self.blurEffect = .dark
      case "extraLight": self.blurEffect = .extraLight
      default: self.blurEffect = nil
      }
    } else {
      blurEffect = nil
    }
    enablePrivacy = args?["enablePrivacyIos"] as? Bool ?? false
    autoLockAfterSeconds = args?["autoLockAfterSecondsIos"] as? Double ?? -1
    lockWithDidEnterBackground = args?["iosLockWithDidEnterBackground"] as? Bool ?? true
    result(true)
  }

  func hexStringToUIColor(hex: String) -> UIColor {
    var colorString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if colorString.hasPrefix("#") { colorString.remove(at: colorString.startIndex) }
    guard colorString.count == 6 else { return .gray }
    var rgbValue: UInt64 = 0
    Scanner(string: colorString).scanHexInt64(&rgbValue)
    return UIColor(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: 1.0)
  }
}
