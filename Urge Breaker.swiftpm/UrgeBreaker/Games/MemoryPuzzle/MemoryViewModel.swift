import SwiftUI
import Combine

@MainActor
class MemoryViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = Constants.gameDuration
    @Published var isGameOver: Bool = false
    
    @Published var currentSequence: [MemoryGame.Item] = []
    @Published var playerSequence: [MemoryGame.Item] = []
    @Published var isShowingSequence: Bool = false
    @Published var message: String = "Watch the pattern"
    @Published var flashColor: Color? = nil
    
    var onComplete: (() -> Void)?
    private var timer: AnyCancellable?
    private var sequenceLength: Int = 3
    
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
        startNewRound()
    }
    
    func endGame() {
        timer?.cancel()
        isGameOver = true
        onComplete?()
    }
    
    private func startNewRound() {
        playerSequence.removeAll()
        isShowingSequence = true
        message = "Watch closely..."
        currentSequence = MemoryGame.generateSequence(length: sequenceLength)
        playSequence()
    }
    
    private func playSequence() {
        // Flash each item in sequence
        var delay = 0.5
        for item in currentSequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.flash(color: item.color)
            }
            delay += 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.isShowingSequence = false
            self?.message = "Repeat the pattern"
        }
    }
    
    private func flash(color: Color) {
        withAnimation {
            flashColor = color
        }
        Haptics.playLight()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            withAnimation {
                self?.flashColor = nil
            }
        }
    }
    
    func playerTapped(color: Color) {
        guard !isShowingSequence else { return }
        
        flash(color: color)
        
        guard playerSequence.count < currentSequence.count else { return }
        let expectedItem = currentSequence[playerSequence.count]
        if color == expectedItem.color {
            // Correct
            playerSequence.append(expectedItem)
            if playerSequence.count == currentSequence.count {
                // Round complete
                score += 10
                Haptics.playSuccess()
                sequenceLength += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.startNewRound()
                }
            }
        } else {
            // Wrong
            Haptics.playMedium()
            message = "Try again!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.startNewRound()
            }
        }
    }
}
