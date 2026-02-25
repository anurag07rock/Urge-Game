import Foundation

enum Trigger: String, Codable, CaseIterable, Identifiable {
    case stress
    case boredom
    case loneliness
    case habit
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .stress: return "Stress"
        case .boredom: return "Boredom"
        case .loneliness: return "Loneliness"
        case .habit: return "Habit"
        }
    }
    
    var icon: String {
        switch self {
        case .stress: return "bolt.fill"
        case .boredom: return "ellipsis.bubble.fill"
        case .loneliness: return "person.fill.questionmark"
        case .habit: return "repeat"
        }
    }
}
