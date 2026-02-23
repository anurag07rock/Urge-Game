import Foundation

struct UrgeSession: Codable, Identifiable {
    let id: UUID
    let startedAt: Date
    var endedAt: Date?
    let gameType: GameType
    var completed: Bool
    var urgeIntensityBefore: Int?
    var urgeIntensityAfter: Int?
    var urgePassed: Bool
    var trigger: Trigger?
    var pointsEarned: Int
    
    init(id: UUID = UUID(), gameType: GameType, intensityBefore: Int? = nil) {
        self.id = id
        self.startedAt = Date()
        self.gameType = gameType
        self.completed = false
        self.urgeIntensityBefore = intensityBefore
        self.urgePassed = false
        self.pointsEarned = 0
    }
}
