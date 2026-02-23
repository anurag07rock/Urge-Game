import Foundation

enum GameType: String, Codable, CaseIterable, Identifiable {
    case breathing
    case stressSmash
    case focusSniper
    case rhythmPulse
    case memoryPuzzle
    case grounding
    case focusHold
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .breathing: return "Breathing"
        case .stressSmash: return "Stress Smash"
        case .focusSniper: return "Focus Sniper"
        case .rhythmPulse: return "Rhythm Pulse"
        case .memoryPuzzle: return "Brain Flip"
        case .grounding: return "Grounding"
        case .focusHold: return "Freeze Challenge"
        }
    }
    
    var description: String {
        switch self {
        case .breathing: return "Calm your mind with guided breathing."
        case .stressSmash: return "Break objects to release tension."
        case .focusSniper: return "Tap correct targets to sharpen focus."
        case .rhythmPulse: return "Tap in sync with calming beats."
        case .memoryPuzzle: return "Challenge your memory with cards."
        case .grounding: return "Reconnect with your senses."
        case .focusHold: return "Hold steady to build resistance."
        }
    }
    
    var instructionSteps: [String] {
        switch self {
        case .breathing:
            return [
                "Follow the circle as it expands.",
                "Inhale as it grows.",
                "Exhale as it shrinks.",
                "Stay with your breath until time ends."
            ]
        case .stressSmash:
            return [
                "Tap the objects to break them.",
                "Release your tension with every smash.",
                "Keep smashing until time runs out."
            ]
        case .focusSniper:
            return [
                "Moving targets will appear.",
                "Tap only the correct ones.",
                "Avoid the traps.",
                "Maintain focus for 30 seconds."
            ]
        case .rhythmPulse:
            return [
                "Listen to the calming rhythm.",
                "Tap the pulse when it hits the center.",
                "Stay in sync to build a calm streak.",
                "Find your flow."
            ]
        case .memoryPuzzle:
            return [
                "Watch the cards carefully.",
                "Find the matching pairs.",
                "Clear the board before time runs out."
            ]
        case .focusHold:
            return [
                "Press and hold the circle.",
                "Do not lift your finger.",
                "If you release, progress is reduced.",
                "Hold steady until time ends."
            ]
        case .grounding:
            return [
                "Read the prompt.",
                "Reflect briefly.",
                "Tap confirm.",
                "Move through all grounding steps."
            ]
        }
    }
}
