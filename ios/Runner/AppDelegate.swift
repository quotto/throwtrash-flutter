import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var backgroundTasks: [String: UIBackgroundTaskIdentifier] = [:]

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }
    let controller = window?.rootViewController as! FlutterViewController
    let backgroundTaskChannel = FlutterMethodChannel(
      name: "throwtrash/background_task",
      binaryMessenger: controller.binaryMessenger
    )
    backgroundTaskChannel.setMethodCallHandler { [weak self] call, result in
      self?.handleBackgroundTaskCall(call, result: result)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleBackgroundTaskCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "start":
      let arguments = call.arguments as? [String: Any]
      let name = arguments?["name"] as? String ?? "throwtrash_background_task"
      let taskId = UUID().uuidString
      let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
        self?.endBackgroundTask(taskId)
      }
      if backgroundTask == .invalid {
        result(nil)
        return
      }
      backgroundTasks[taskId] = backgroundTask
      result(taskId)
    case "end":
      let arguments = call.arguments as? [String: Any]
      if let taskId = arguments?["id"] as? String {
        endBackgroundTask(taskId)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func endBackgroundTask(_ taskId: String) {
    guard let backgroundTask = backgroundTasks.removeValue(forKey: taskId) else {
      return
    }
    UIApplication.shared.endBackgroundTask(backgroundTask)
  }
}
