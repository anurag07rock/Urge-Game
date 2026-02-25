import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var primaryTriggers: [Trigger]
    
    // Phase 3 Settings
    var notificationsEnabled: Bool
    var wellnessRemindersEnabled: Bool
    var focusShieldEnabled: Bool
    
    var level: Int {
        return (totalPoints / 100) + 1
    }
    
    var progressToNextLevel: Double {
        let pointsInCurrentLevel = totalPoints % 100
        return Double(pointsInCurrentLevel) / 100.0
    }
    
    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.totalPoints = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastCompletedDate = nil
        self.primaryTriggers = []
        self.notificationsEnabled = true
        self.wellnessRemindersEnabled = true
        self.focusShieldEnabled = false
    }
}
