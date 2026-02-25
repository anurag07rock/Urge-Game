import UIKit

@MainActor
struct Haptics {
    private static let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private static let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private static let notificationGenerator = UINotificationFeedbackGenerator()
    private static let selectionGenerator = UISelectionFeedbackGenerator()
    
    static func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    static func playLight() {
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }
    
    static func playMedium() {
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }
    
    static func playHeavy() {
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }
    
    static func playSuccess() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }
    
    static func playSelection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
}
