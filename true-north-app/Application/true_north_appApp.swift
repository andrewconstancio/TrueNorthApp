import SwiftUI

@main
struct GoalTrackerApp: App {
    /// The app delegate adapter for this app.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// The auth view model state object.
    @StateObject var viewModel = AuthViewModel()
    
    /// The notification manager state object.
    @StateObject var notificationManager = NotificationService()
    
    /// Persistent data container for Core Data.
    @StateObject var persistentContainer = PersistenceController()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.colorScheme, .dark)
                .environmentObject(viewModel)
                .environmentObject(notificationManager)
                .environment(\.managedObjectContext, persistentContainer.container.viewContext)
                .task {
                    await notificationManager.request()
                }
        }
    }
}
