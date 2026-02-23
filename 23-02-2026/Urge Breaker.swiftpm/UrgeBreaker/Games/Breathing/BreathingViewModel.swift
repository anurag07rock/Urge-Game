import SwiftUI
import Combine

@MainActor
class BreathingViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = Constants.gameDuration
    @Published var isGameOver: Bool = false
    @Published var phase: BreathingGame.Phase = .inhale
    @Published var scale: CGFloat = 0.5
    
    var onComplete: (() -> Void)?
    private var timer: AnyCancellable?
    private var phaseTimer: AnyCancellable?
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        startTimer()
        startBreathingCycle()
    }
    
    func endGame() {
        timer?.cancel()
        phaseTimer?.cancel()
        isGameOver = true
        onComplete?()
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
    }
    
    private func startBreathingCycle() {
        // 4 in, 4 out cycle
        runPhase(.inhale, duration: 4)
    }
    
    private func runPhase(_ newPhase: BreathingGame.Phase, duration: TimeInterval) {
        withAnimation(.easeInOut(duration: duration)) {
            self.phase = newPhase
            self.scale = (newPhase == .inhale) ? 1.0 : 0.5
        }
        
        // Haptics at start of phase
        Haptics.playLight()
        
        // Schedule next phase
        phaseTimer = Timer.publish(every: duration, on: .main, in: .common).autoconnect()
            .first() // Only fire once
            .sink { [weak self] _ in
                guard let self = self, !self.isGameOver else { return }
                self.score += 1 // Point for completing a phase
                let nextPhase: BreathingGame.Phase = (self.phase == .inhale) ? .exhale : .inhale
                self.runPhase(nextPhase, duration: 4)
            }
    }
}
