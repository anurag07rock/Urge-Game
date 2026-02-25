import SwiftUI
import Combine

struct PatternItem: Identifiable {
    let id = UUID()
    let display: String
    let color: Color
    let icon: String?
    var isOddOneOut: Bool
}

struct PatternRound {
    let items: [PatternItem]
    let correctIndex: Int
    let difficulty: Int
    let explanation: String
}

@MainActor
class PatternBreakViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 90
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var currentRound: Int = 0
    @Published var totalRounds: Int = 5
    @Published var items: [PatternItem] = []
    @Published var correctIndex: Int = 0
    @Published var showFeedback: String = ""
    @Published var showFastBonus: Bool = false
    @Published var hintQuadrant: Int? = nil
    @Published var showCountdown: Bool = true
    @Published var countdownValue: Int = 3
    @Published var showCompletion: Bool = false
    @Published var speedBonusPoints: Int = 0
    @Published var answeredCorrectly: Bool = false
    @Published var wrongIndex: Int? = nil
    
    private var gameTimer: AnyCancellable?
    private var roundStartTime: Date?
    private let speedThreshold: TimeInterval = 3.0
    
    // Pre-defined rounds pool
    private let roundPool: [(items: [(String, Color, Bool)], difficulty: Int, explanation: String)] = [
        // Easy: colored shapes
        ([(("🔵", .blue, false)), (("🔵", .blue, false)), (("🔵", .blue, false)), (("🔴", .red, true))], 1, "Three blue, one red"),
        ([(("🟢", .green, false)), (("🟢", .green, false)), (("🟡", .yellow, true)), (("🟢", .green, false))], 1, "Three green, one yellow"),
        ([(("⬛", .primary, true)), (("🟣", .purple, false)), (("🟣", .purple, false)), (("🟣", .purple, false))], 1, "Three purple, one black"),
        ([(("🟠", .orange, false)), (("🟠", .orange, false)), (("🟠", .orange, false)), (("⚪", .white, true))], 1, "Three orange, one white"),
        ([(("🔴", .red, false)), (("🔴", .red, true)), (("🔵", .blue, false)), (("🔵", .blue, false))], 1, "Two groups — spot the mismatch"),
        // Medium: numbers
        ([(("2", .primary, false)), (("4", .primary, false)), (("6", .primary, false)), (("9", .primary, true))], 2, "Even sequence broken by 9"),
        ([(("10", .primary, false)), (("20", .primary, false)), (("30", .primary, false)), (("35", .primary, true))], 2, "Tens sequence broken"),
        ([(("3", .primary, false)), (("6", .primary, false)), (("9", .primary, false)), (("11", .primary, true))], 2, "Multiples of 3 broken"),
        ([(("1", .primary, false)), (("3", .primary, false)), (("7", .primary, true)), (("5", .primary, false))], 2, "Odd sequence broken"),
        ([(("5", .primary, false)), (("10", .primary, false)), (("15", .primary, false)), (("22", .primary, true))], 2, "5s sequence broken"),
        ([(("100", .primary, false)), (("200", .primary, false)), (("300", .primary, false)), (("450", .primary, true))], 2, "Hundreds broken"),
        ([(("7", .primary, false)), (("14", .primary, false)), (("21", .primary, false)), (("30", .primary, true))], 2, "Multiples of 7 broken"),
        // Hard: icons/symbols
        ([(("→", .primary, false)), (("→", .primary, false)), (("→", .primary, false)), (("↑", .primary, true))], 3, "Three right arrows, one up"),
        ([(("★", .primary, false)), (("★", .primary, false)), (("☆", .primary, true)), (("★", .primary, false))], 3, "Filled vs empty star"),
        ([(("♠", .primary, false)), (("♠", .primary, false)), (("♦", .primary, true)), (("♠", .primary, false))], 3, "Spades vs diamond"),
        ([(("△", .primary, false)), (("△", .primary, false)), (("△", .primary, false)), (("□", .primary, true))], 3, "Triangles vs square"),
        ([(("◉", .primary, false)), (("◉", .primary, false)), (("◎", .primary, true)), (("◉", .primary, false))], 3, "Filled vs outlined circle"),
        ([(("✚", .primary, false)), (("✚", .primary, false)), (("✖", .primary, true)), (("✚", .primary, false))], 3, "Plus vs X"),
        ([(("♩", .primary, false)), (("♩", .primary, false)), (("♩", .primary, false)), (("♫", .primary, true))], 3, "Single vs double note"),
        ([(("◆", .primary, false)), (("◆", .primary, false)), (("◆", .primary, false)), (("●", .primary, true))], 3, "Diamonds vs circle"),
    ]
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        speedBonusPoints = 0
        currentRound = 0
        isGameOver = false
        showCompletion = false
        showCountdown = true
        countdownValue = 3
        
        // Countdown sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in self?.countdownValue = 2 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in self?.countdownValue = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.showCountdown = false
            self?.loadNextRound()
        }
    }
    
    private var selectedRounds: [Int] = []
    
    func loadNextRound() {
        guard currentRound < totalRounds else {
            showCompletion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.endGame()
            }
            return
        }
        
        answeredCorrectly = false
        wrongIndex = nil
        hintQuadrant = nil
        showFeedback = ""
        showFastBonus = false
        
        // Pick round by difficulty
        let targetDifficulty: Int
        if currentRound < 2 { targetDifficulty = 1 }
        else if currentRound < 4 { targetDifficulty = 2 }
        else { targetDifficulty = 3 }
        
        let availableRounds = roundPool.enumerated().filter { $0.element.difficulty == targetDifficulty && !selectedRounds.contains($0.offset) }
        
        guard let chosen = availableRounds.randomElement() else {
            // Fallback
            endGame()
            return
        }
        
        selectedRounds.append(chosen.offset)
        let roundData = chosen.element
        
        // Build items and find correct index
        var roundItems: [PatternItem] = []
        var foundCorrect = -1
        for (i, item) in roundData.items.enumerated() {
            roundItems.append(PatternItem(display: item.0, color: item.1, icon: nil, isOddOneOut: item.2))
            if item.2 { foundCorrect = i }
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            items = roundItems
            correctIndex = foundCorrect
        }
        
        roundStartTime = Date()
        currentRound += 1
    }
    
    func tapItem(at index: Int) {
        guard !answeredCorrectly && !isGameOver && !showCompletion else { return }
        
        if index == correctIndex {
            // Correct!
            answeredCorrectly = true
            score += 1
            
            // Speed bonus
            if let startTime = roundStartTime {
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed < speedThreshold {
                    speedBonusPoints += 1
                    score += 1
                    showFastBonus = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.showFastBonus = false
                    }
                }
            }
            
            Haptics.playSuccess()
            showFeedback = "Nice catch!"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.loadNextRound()
            }
        } else {
            // Wrong
            wrongIndex = index
            // Give quadrant hint
            hintQuadrant = correctIndex
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.wrongIndex = nil
            }
        }
    }
    
    var completionMessage: String {
        let total = score
        if total >= 8 {
            return "Your pattern recognition is sharp! Habits don't stand a chance."
        } else if total >= 5 {
            return "Good focus. The more you practice, the faster habits get intercepted."
        } else {
            return "You showed up. That's the hardest part."
        }
    }
    
    func endGame() {
        isGameOver = true
        onComplete?()
    }
}
