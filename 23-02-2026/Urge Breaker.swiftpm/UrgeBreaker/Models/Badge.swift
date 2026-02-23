import Foundation

struct Badge: Codable, Identifiable {
    let id: UUID
    let name: String
    let iconName: String
    var unlocked: Bool
}
