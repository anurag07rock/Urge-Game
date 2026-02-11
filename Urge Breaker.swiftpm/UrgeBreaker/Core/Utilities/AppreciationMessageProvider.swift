import Foundation

struct AppreciationMessageProvider {
    private static let messages = [
        "You showed up for yourself.",
        "That pause matters.",
        "You just interrupted the urge.",
        "Small wins build strength.",
        "You are taking control.",
        "Every second counts.",
        "Good job listening to yourself.",
        "You're building a new habit.",
        "Breathe. You did it.",
        "One step at a time."
    ]
    
    static func getRandomMessage() -> String {
        messages.randomElement() ?? "You showed up for yourself."
    }
}
