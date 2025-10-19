import SwiftUI

//private struct FirebaseServiceKey: EnvironmentKey {
//    static let defaultValue: FirebaseServiceProtocol = FirebaseService()
//}
//
//extension EnvironmentValues {
//    var firebaseService: FirebaseServiceProtocol {
//        get { self[FirebaseServiceKey.self] }
//        set { self[FirebaseServiceKey.self] = newValue }
//    }
//}

@main
struct GoalTrackerApp: App {
    /// The app delegate adapter for this app.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// The notification manager state object.
    @StateObject var notificationManager = NotificationService()
    
    /// Persistent data container for Core Data.
    @StateObject var persistentContainer = PersistenceController()
    
    /// The firebase service object.
    private var firebaseService = FirebaseService()

    var body: some Scene {
        WindowGroup {
            RootView(firebaseService: firebaseService)
                .environment(\.colorScheme, .dark)
                .environmentObject(notificationManager)
                .environment(\.managedObjectContext, persistentContainer.container.viewContext)
                .task {
                    await notificationManager.request()
                }
        }
    }
}
