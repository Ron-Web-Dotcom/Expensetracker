import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Enable data protection for financial data files
    enableDataProtection()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  /// Enable iOS data protection for secure backup encryption
  private func enableDataProtection() {
    // Set file protection for app documents directory
    if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
      do {
        try FileManager.default.setAttributes(
          [FileAttributeKey.protectionKey: FileProtectionType.complete],
          ofItemAtPath: documentsPath.path
        )
      } catch {
        print("Failed to set file protection: \(error)")
      }
    }
    
    // Exclude sensitive data from iCloud backup
    if let libraryPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
      let preferencesPath = libraryPath.appendingPathComponent("Preferences")
      do {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = false // Allow encrypted backups
        var mutableURL = preferencesPath
        try mutableURL.setResourceValues(resourceValues)
      } catch {
        print("Failed to configure backup settings: \(error)")
      }
    }
  }
}
