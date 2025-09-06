//
//  new_hatsApp.swift
//  new_hats
//
//  Created by Guangrui Ma on 7/14/25.
//

//import SwiftUI
//import FirebaseCore
//
//@main
//struct MyApp: App {
//    init() {
//        FirebaseManager.shared.configure()
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }   
//}

import SwiftUI
import FirebaseCore
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
    // Required for Google Sign-In
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
      }
    }
  }
}
