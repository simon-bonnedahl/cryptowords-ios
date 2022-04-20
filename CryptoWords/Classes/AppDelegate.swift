//
//  AppDelegate.swift
//  Codenames
//
//  Created by Simon Bonnedahl on 2021-12-28.

import AVFoundation
import GoogleCast
import UIKit
import Firebase

let appDelegate = (UIApplication.shared.delegate as? AppDelegate)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  let kReceiverAppID = "B447C75C"
  var namespace = "urn:x-cast:ch.cimnine.chromecast-cryptowords.text"
  fileprivate var enableSDKLogging = false
  var orientationLock = UIInterfaceOrientationMask.all
  
  var window: UIWindow?

  func application(_: UIApplication,
                   didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: kReceiverAppID))
    options.physicalVolumeButtonsWillControlDeviceVolume = true
    GCKCastContext.setSharedInstanceWith(options)
    FirebaseApp.configure()
      
    GCKUICastButton.appearance().tintColor = UIColor.gray
    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
      // Sets shadow (line below the bar) to a blank image
    UINavigationBar.appearance().shadowImage = UIImage()
      // Sets the translucent background color
    UINavigationBar.appearance().backgroundColor = .clear
    UINavigationBar.appearance().isTranslucent = true

    window?.clipsToBounds = true
    setupCastLogging()
      
  
      
    GCKCastContext.sharedInstance().sessionManager.add(self)
      return true
  }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }

 func setupCastLogging() {
    let logFilter = GCKLoggerFilter()
    let classesToLog = ["GCKDeviceScanner", "GCKDeviceProvider", "GCKDiscoveryManager", "GCKCastChannel",
                        "GCKMediaControlChannel", "GCKUICastButton", "GCKUIMediaController", "NSMutableDictionary"]
    logFilter.setLoggingLevel(.verbose, forClasses: classesToLog)
    GCKLogger.sharedInstance().filter = logFilter
    GCKLogger.sharedInstance().delegate = self
  }
  func applicationWillTerminate(_: UIApplication) {
    NotificationCenter.default.removeObserver(self,
                                              name: NSNotification.Name.gckExpandedMediaControlsTriggered,
                                              object: nil)
  }
}

// MARK: - GCKLoggerDelegate
extension AppDelegate: GCKLoggerDelegate {
  func logMessage(_ message: String,
                  at _: GCKLoggerLevel,
                  fromFunction function: String,
                  location: String) {
    if enableSDKLogging {
      // Send SDK's log messages directly to the console.
      print("\(location): \(function) - \(message)")
    }
  }
}

// MARK: - GCKSessionManagerListener

extension AppDelegate: GCKSessionManagerListener {
  func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
    if error == nil {
      
    } else {
      let message = "Session ended unexpectedly:\n\(error?.localizedDescription ?? "")"
      showAlert(withTitle: "Session error", message: message)
    }
  }

  func sessionManager(_: GCKSessionManager, didFailToStart _: GCKSession, withError error: Error) {
    let message = "Failed to start session:\n\(error.localizedDescription)"
    showAlert(withTitle: "Session error", message: message)
  }

  func showAlert(withTitle title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default))
    window?.rootViewController?.present(alert, animated: true, completion: nil)
  }
}

