import UIKit
import Foundation
import UserNotifications
import FirebaseMessaging

@MainActor
class NotificationService: ObservableObject {
    @Published private(set) var hasPermission = false
    @Published private(set) var fcmToken: String?
    
    init() {
        Task {
            await getAuthStatus()
        }
    }
    
    func request() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await getAuthStatus()

            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("User denied notification permission")
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
    }
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
        default:
            hasPermission = false
        }
    }
    
    func sendLocalNotification(title: String, body: String, timeInterval: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error)")
            } else {
                print("Local notification scheduled successfully")
            }
        }
    }
}
