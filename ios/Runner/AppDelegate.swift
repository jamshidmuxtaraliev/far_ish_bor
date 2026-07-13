import Flutter
import UIKit
import GoogleMaps
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps API kaliti — o'zingizning kalitingizni qo'ying.
    // https://console.cloud.google.com → Maps SDK for iOS
    GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
    // Yandex MapKit API kaliti — east_quest bilan bir xil.
    YMKMapKit.setApiKey("a4ea036d-8925-4c9c-8360-73d09445e5a5")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
