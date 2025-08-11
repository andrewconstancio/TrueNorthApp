import SwiftUI

@main
struct GoalTrackerApp: App {
    /// The app delegate adapter for this app.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// The auth view model state object.
    @StateObject var viewModel = AuthViewModel()
    
    /// The notification manager state object.
    @StateObject var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .environmentObject(notificationManager)
                .task {
                    await notificationManager.request()
                }
        }
    }
}
