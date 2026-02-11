import Foundation

struct Reward: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    var unlockedAt: Date?
    
    var isUnlocked: Bool {
        unlockedAt != nil
    }
}
