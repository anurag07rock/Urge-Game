import Foundation

enum GameType: String, Codable, CaseIterable, Identifiable {
    case breathing
    case tapChallenge
    case memoryPuzzle
    case grounding
    case focusHold
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .breathing: return "Breathing"
        case .tapChallenge: return "Tap Challenge"
        case .memoryPuzzle: return "Memory Puzzle"
        case .grounding: return "Grounding Focus"
        case .focusHold: return "Focus Hold"
        }
    }
    
    var description: String {
        switch self {
        case .breathing: return "Calm your mind with guided breathing."
        case .tapChallenge: return "Release energy by tapping fast."
        case .memoryPuzzle: return "Distract yourself with a memory game."
        case .grounding: return "Reconnect with your senses."
        case .focusHold: return "Build resistance by holding still."
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
        case .tapChallenge:
            return [
                "Tap the circle as fast as you can.",
                "Watch your count increase.",
                "Keep going until time runs out."
            ]
        case .memoryPuzzle:
            return [
                "Watch the sequence carefully.",
                "Remember the order.",
                "Repeat it correctly.",
                "Sequences grow longer as you succeed."
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
