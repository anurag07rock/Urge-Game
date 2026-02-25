import SwiftUI
import Combine

@MainActor
class FocusHoldViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = Constants.gameDuration
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var isHolding: Bool = false
    @Published var holdProgress: Double = 0.0 // 0 to 1
    @Published var feedbackMessage: String = "Press and Hold"
    @Published var circleScale: CGFloat = 1.0
    
    private var timer: AnyCancellable?
    private let totalDuration: TimeInterval = Constants.gameDuration
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        isGameOver = false
        timeRemaining = totalDuration
        score = 0
        isHolding = false
        holdProgress = 0.0
        feedbackMessage = "Press and Hold"
        circleScale = 1.0
    }
    
    func startHolding() {
        isHolding = true
        feedbackMessage = "Keep Holding..."
        Haptics.playMedium()
        
        // Start Timer
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateGameLoop()
            }
    }
    
    func stopHolding() {
        isHolding = false
        feedbackMessage = "Don't Let Go!"
        timer?.cancel()
        timer = nil
        Haptics.playLight() // Warning haptic
        
        // Penalty or pause logic
        // For this version: Pause and reset progress slightly to encourage holding
        withAnimation {
            circleScale = 1.0
        }
    }
    
    private func updateGameLoop() {
        guard isHolding else { return }
        
        if timeRemaining > 0 {
            timeRemaining -= 0.1
            holdProgress = 1.0 - (timeRemaining / totalDuration)
            score = Int(holdProgress * 100) // Score based on % held
            
            // Breathing animation effect on circle
            withAnimation(.easeInOut(duration: 1.0)) {
                circleScale = 1.0 + (0.05 * sin(timeRemaining * 2))
            }
            
        } else {
            endGame()
        }
    }
    
    func endGame() {
        timer?.cancel()
        timer = nil
        isGameOver = true
        onComplete?()
    }
}
