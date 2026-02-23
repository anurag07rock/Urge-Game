import SwiftUI
import Combine

@MainActor
class RhythmPulseViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var timeRemaining: TimeInterval = 30
    @Published var isGameOver: Bool = false
    
    @Published var pulseSize: CGFloat = 300
    @Published var pulseOpacity: Double = 0
    @Published var feedbackText: String = ""
    @Published var feedbackColor: Color = .ubPrimary
    
    var onComplete: (() -> Void)?
    private var timer: AnyCancellable?
    private var animationTimer: AnyCancellable?
    
    private let targetSize: CGFloat = 100
    private let tolerancePerfect: CGFloat = 15
    private let toleranceGood: CGFloat = 40
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        streak = 0
        timeRemaining = 30
        isGameOver = false
        
        // Game Timer
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
            
        startPulse()
    }
    
    private func startPulse() {
        pulseSize = 300
        pulseOpacity = 0
        
        withAnimation(.linear(duration: 1.5)) {
            pulseSize = 0
            pulseOpacity = 1.0
        }
        
        // Reset pulse after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if !self.isGameOver {
                self.startPulse()
            }
        }
    }
    
    func tap() {
        guard !isGameOver else { return }
        
        let diff = abs(pulseSize - targetSize)
        
        if diff < tolerancePerfect {
            score += 50
            streak += 1
            feedbackText = "PERFECT!"
            feedbackColor = .ubSuccess
            Haptics.playMedium()
        } else if diff < toleranceGood {
            score += 20
            streak += 1
            feedbackText = "GOOD"
            feedbackColor = .ubPrimary
            Haptics.playLight()
        } else {
            streak = 0
            feedbackText = "MISS"
            feedbackColor = .ubDanger
            Haptics.playHeavy()
        }
        
        // Clear feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.feedbackText = ""
        }
    }
    
    func endGame() {
        timer?.cancel()
        isGameOver = true
        onComplete?()
    }
}
