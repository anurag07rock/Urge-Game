import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    var totalPoints: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    
    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.totalPoints = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastCompletedDate = nil
    }
}
