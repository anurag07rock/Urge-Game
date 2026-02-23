import Foundation

struct BreathingGame {
    // Breathing logic is mostly time-based, so minimal state here
    enum Phase: String {
        case inhale = "Inhale"
        case exhale = "Exhale"
        case hold = "Hold" // Optional, but not specified in prompt
    }
}
