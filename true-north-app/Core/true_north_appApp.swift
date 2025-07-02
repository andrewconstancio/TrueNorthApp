//
//  true_north_appApp.swift
//  true-north-app
//
//  Created by Andrew Constancio on 6/19/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .prod) // or .sandbox
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }

        // Handle other notifications here if needed
        completionHandler(.newData)
    }
}

@main
struct GoalTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var viewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack{
                ContentView()
            }
            .environmentObject(viewModel)
        }
    }
}

struct ExploreView: View {
    var body: some View {
        NavigationView {
            Text("Explore View")
                .navigationTitle("Explore")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Text("Settings View")
                .navigationTitle("Settings")
        }
    }
}
