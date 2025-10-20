import SwiftUI

private struct FirebaseServiceKey: EnvironmentKey {
    static let defaultValue: FirebaseServiceProtocol = FirebaseService()
}

extension EnvironmentValues {
    var firebaseService: FirebaseServiceProtocol {
        get { self[FirebaseServiceKey.self] }
        set { self[FirebaseServiceKey.self] = newValue }
    }
}

@main
struct GoalTrackerApp: App {
    /// The app delegate adapter for this app.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// The notification manager state object.
    @StateObject var notificationManager = NotificationService()
    
    /// The firebase service object.
    private let firebaseService = FirebaseService()

    var body: some Scene {
        WindowGroup {
            RootView(
                authVM: AuthViewModel(firebaseService: firebaseService),
                goalViewModel: GoalViewModel(firebaseService: firebaseService)
            )
            .environment(\.colorScheme, .dark)
            .environment(\.firebaseService, firebaseService)
            .environmentObject(notificationManager)
            .task {
                await notificationManager.request()
            }
        }
    }
}
