import UIKit
import Flutter
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter local notification settings
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    WorkmanagerPlugin.registerTask(withIdentifier: "com.codegemz.helloWorld")
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let alarmChannel = FlutterMethodChannel(name: "net.mythrowtrash/alarm", binaryMessenger: controller as! FlutterBinaryMessenger)
    alarmChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        switch call.method {
        case "reserveNextAlarm":
            guard let args = call.arguments as? [String: String] else {return}

            let now = Date()
            var nextDate = now.addingTimeInterval(Double(args["duration"]!)!)
            let cal = Calendar(identifier: .gregorian)
            var dateComponentsDay = cal.dateComponents(in: TimeZone.current, from:nextDate)

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponentsDay, repeats: false)

            let content = UNMutableNotificationContent()
            content.title = "AndroidLikeAlerm"
            content.body = args["content"]!
            content.sound = UNNotificationSound.default

            let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)

            let notificationCenter = UNUserNotificationCenter.current()

            notificationCenter.add(request) { (error) in
               if error != nil {
                   print(error.debugDescription)
               }
            }
            result("alarm set")
        default:
            print("method channel not match")
            result(FlutterMethodNotImplemented)
        }
    })

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
