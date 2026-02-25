import SwiftUI
import Combine

@MainActor
class TapViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = Constants.gameDuration
    @Published var isGameOver: Bool = false
    @Published var buttonScale: CGFloat = 1.0
    
    var onComplete: (() -> Void)?
    private var timer: AnyCancellable?
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
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
    
    func tap() {
        guard !isGameOver else { return }
        score += 1
        Haptics.playLight()
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            buttonScale = 0.9
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                self?.buttonScale = 1.0
            }
        }
    }
    
    func endGame() {
        timer?.cancel()
        isGameOver = true
        onComplete?()
    }
}
