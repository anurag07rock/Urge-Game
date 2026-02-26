import Foundation

enum GameType: String, Codable, CaseIterable, Identifiable {
    case logicCodeBreaker
    case minimal2048
    case zenSudoku
    case slidingPuzzle
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .logicCodeBreaker: return "Logic Code Breaker"
        case .minimal2048: return "Minimal 2048"
        case .zenSudoku: return "Zen Sudoku"
        case .slidingPuzzle: return "Sliding Puzzle"
        }
    }
    
    var description: String {
        switch self {
        case .logicCodeBreaker: return "Crack a secret 3-digit code using logic and deduction."
        case .minimal2048: return "Merge tiles to reach higher numbers on a 4×4 grid."
        case .zenSudoku: return "Place numbers 1–4 with no repeats in rows, columns, or boxes."
        case .slidingPuzzle: return "Slide numbered tiles into the correct order."
        }
    }
    
    var instructionSteps: [String] {
        switch self {
        case .logicCodeBreaker:
            return [
                "A secret 3-digit code is generated (digits 1–9, no repeats).",
                "Enter your guess using the number pad.",
                "After each guess, you'll see feedback:",
                "✅ = correct digit & position, 🔄 = correct digit, wrong position, ❌ = not in code.",
                "Crack the code within 8 attempts to win!"
            ]
        case .minimal2048:
            return [
                "Swipe in any direction to slide all tiles.",
                "Matching tiles merge and double their value.",
                "A new tile (2 or 4) appears after each move.",
                "Keep merging to reach higher numbers!",
                "Game ends when no moves remain."
            ]
        case .zenSudoku:
            return [
                "Fill the 4×4 grid with numbers 1–4.",
                "Each row must contain 1–4 with no repeats.",
                "Each column must contain 1–4 with no repeats.",
                "Each 2×2 box must contain 1–4 with no repeats.",
                "Tap a cell, then tap a number below to place it."
            ]
        case .slidingPuzzle:
            return [
                "8 numbered tiles sit in a 3×3 grid with one empty space.",
                "Tap a tile adjacent to the empty space to slide it.",
                "Arrange all tiles in order: 1–8, with empty space last.",
                "Try to solve it in as few moves as possible!"
            ]
        }
    }
    
    var icon: String {
        switch self {
        case .logicCodeBreaker: return "lock.shield.fill"
        case .minimal2048: return "square.grid.2x2.fill"
        case .zenSudoku: return "number.square.fill"
        case .slidingPuzzle: return "square.grid.3x3.fill"
        }
    }
}
