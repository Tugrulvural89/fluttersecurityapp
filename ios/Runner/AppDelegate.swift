import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] {
        GMSServices.provideAPIKey(apiKey)
    } else {
        print("Google Maps API Key not found in environment variables.")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
