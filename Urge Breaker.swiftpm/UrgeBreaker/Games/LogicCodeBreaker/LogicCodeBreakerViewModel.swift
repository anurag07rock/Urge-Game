import SwiftUI

// MARK: - Logic Code Breaker ViewModel (Mastermind-style 3-digit code)
@MainActor
class LogicCodeBreakerViewModel: ObservableObject {
    
    struct Guess: Identifiable {
        let id = UUID()
        let digits: [Int]
        let feedback: [DigitFeedback]
    }
    
    enum DigitFeedback {
        case correctPosition  // ✅
        case wrongPosition    // 🔄
        case notPresent       // ❌
    }
    
    enum GameState: Equatable {
        case playing
        case won
        case lost
    }
    
    @Published var currentInput: [Int] = []
    @Published var guesses: [Guess] = []
    @Published var gameState: GameState = .playing
    @Published var secretCode: [Int] = []
    
    let maxAttempts = 8
    var onComplete: (() -> Void)?
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        generateNewCode()
    }
    
    func generateNewCode() {
        // Generate 3 unique digits from 1-9
        var available = Array(1...9)
        var code: [Int] = []
        for _ in 0..<3 {
            let index = Int.random(in: 0..<available.count)
            code.append(available.remove(at: index))
        }
        secretCode = code
        currentInput = []
        guesses = []
        gameState = .playing
    }
    
    func addDigit(_ digit: Int) {
        guard currentInput.count < 3, gameState == .playing else { return }
        currentInput.append(digit)
    }
    
    func removeLastDigit() {
        guard !currentInput.isEmpty, gameState == .playing else { return }
        currentInput.removeLast()
    }
    
    func submitGuess() {
        guard currentInput.count == 3, gameState == .playing else { return }
        
        var feedback: [DigitFeedback] = []
        for i in 0..<3 {
            if currentInput[i] == secretCode[i] {
                feedback.append(.correctPosition)
            } else if secretCode.contains(currentInput[i]) {
                feedback.append(.wrongPosition)
            } else {
                feedback.append(.notPresent)
            }
        }
        
        let guess = Guess(digits: currentInput, feedback: feedback)
        guesses.append(guess)
        
        if currentInput == secretCode {
            gameState = .won
            Haptics.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.onComplete?()
            }
        } else if guesses.count >= maxAttempts {
            gameState = .lost
            Haptics.playHeavy()
        }
        
        currentInput = []
    }
    
    func restart() {
        generateNewCode()
    }
}
