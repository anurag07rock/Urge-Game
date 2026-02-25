import SwiftUI
import Combine

@MainActor
class MirrorMindViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 120
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var sequence: [Int] = [] // quadrant indices 0-3
    @Published var playerInput: [Int] = []
    @Published var activeQuadrant: Int? = nil
    @Published var round: Int = 0
    @Published var isShowingSequence: Bool = false
    @Published var showCompletion: Bool = false
    @Published var feedback: String = ""
    
    private let totalRounds = 5
    private var showTimer: AnyCancellable?
    
    let quadrantColors: [Color] = [.cyan, .purple, .blue, .teal]
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        round = 0
        isGameOver = false
        showCompletion = false
        sequence = []
        playerInput = []
        feedback = ""
        
        nextRound()
    }
    
    func nextRound() {
        round += 1
        if round > totalRounds {
            showCompletion = true
            Haptics.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.endGame()
            }
            return
        }
        
        playerInput = []
        // Add one more to the sequence
        sequence.append(Int.random(in: 0...3))
        
        // Show the sequence
        showSequence()
    }
    
    private func showSequence() {
        isShowingSequence = true
        
        for (i, quad) in sequence.enumerated() {
            let delay = Double(i) * 0.8 + 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.activeQuadrant = quad
                }
                Haptics.playLight()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    withAnimation { self?.activeQuadrant = nil }
                }
            }
        }
        
        let totalDelay = Double(sequence.count) * 0.8 + 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) { [weak self] in
            self?.isShowingSequence = false
        }
    }
    
    func tapQuadrant(_ index: Int) {
        guard !isShowingSequence && !isGameOver && !showCompletion else { return }
        
        playerInput.append(index)
        Haptics.playLight()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            activeQuadrant = index
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            withAnimation { self?.activeQuadrant = nil }
        }
        
        // Check input
        let currentIndex = playerInput.count - 1
        if playerInput[currentIndex] != sequence[currentIndex] {
            // Wrong! But no fail state — just replay
            feedback = "Let me show you again..."
            playerInput = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.feedback = ""
                self?.showSequence()
            }
            return
        }
        
        // Check if complete
        if playerInput.count == sequence.count {
            score += 1
            feedback = "✓"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                self?.feedback = ""
                self?.nextRound()
            }
        }
    }
    
    func endGame() {
        isGameOver = true
        onComplete?()
    }
}
