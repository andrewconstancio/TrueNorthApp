import SwiftUI

@main
struct GoalTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var viewModel = AuthViewModel()
    @StateObject var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(notificationManager)
                .task {
                    await notificationManager.request()
                }
        }
    }
}
