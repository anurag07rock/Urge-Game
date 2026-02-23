import Foundation
import UserNotifications

@MainActor
class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized: Bool = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    func requestAuthorization() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                self.isAuthorized = granted
            } catch {
                print("Notification authorization failed: \(error)")
                self.isAuthorized = false
            }
        }
    }
    
    func scheduleWellnessReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Urge Breaker Pulse Check"
        content.body = "Take 5 seconds to check in with yourself. How are you feeling?"
        content.sound = .default
        
        // Schedule for every 4 hours during the day
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 3600, repeats: true)
        let request = UNNotificationRequest(identifier: "wellness_check", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleProactiveReminder(at date: Date, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Protection Active"
        content.body = message
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "proactive_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
