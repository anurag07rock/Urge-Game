import SwiftUI

// MARK: - Minimal 2048 ViewModel
@MainActor
class Minimal2048ViewModel: ObservableObject {
    
    struct Tile: Identifiable, Equatable {
        let id: UUID
        var value: Int
        var row: Int
        var col: Int
        
        init(value: Int, row: Int, col: Int) {
            self.id = UUID()
            self.value = value
            self.row = row
            self.col = col
        }
    }
    
    enum Direction {
        case up, down, left, right
    }
    
    @Published var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @Published var score: Int = 0
    @Published var bestScore: Int = 0
    @Published var isGameOver: Bool = false
    @Published var hasWon: Bool = false
    
    var onComplete: (() -> Void)?
    private let bestScoreKey = "minimal2048BestScore"
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
        startNewGame()
    }
    
    func startNewGame() {
        grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
        score = 0
        isGameOver = false
        hasWon = false
        addRandomTile()
        addRandomTile()
    }
    
    func move(_ direction: Direction) {
        guard !isGameOver else { return }
        
        let oldGrid = grid
        
        switch direction {
        case .left:  moveLeft()
        case .right: moveRight()
        case .up:    moveUp()
        case .down:  moveDown()
        }
        
        if grid != oldGrid {
            addRandomTile()
            saveBestScore()
            
            if !canMove() {
                isGameOver = true
                Haptics.playHeavy()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.onComplete?()
                }
            }
        }
    }
    
    // MARK: - Movement Logic
    
    private func moveLeft() {
        for row in 0..<4 {
            var line = grid[row].filter { $0 != 0 }
            line = mergeLine(line)
            while line.count < 4 { line.append(0) }
            grid[row] = line
        }
    }
    
    private func moveRight() {
        for row in 0..<4 {
            var line = grid[row].filter { $0 != 0 }
            line = mergeLine(line.reversed()).reversed()
            while line.count < 4 { line.insert(0, at: 0) }
            grid[row] = Array(line.prefix(4))
        }
    }
    
    private func moveUp() {
        for col in 0..<4 {
            var line = (0..<4).map { grid[$0][col] }.filter { $0 != 0 }
            line = mergeLine(line)
            while line.count < 4 { line.append(0) }
            for row in 0..<4 { grid[row][col] = line[row] }
        }
    }
    
    private func moveDown() {
        for col in 0..<4 {
            var line = (0..<4).map { grid[$0][col] }.filter { $0 != 0 }
            line = mergeLine(line.reversed()).reversed()
            while line.count < 4 { line.insert(0, at: 0) }
            let result = Array(line.prefix(4))
            for row in 0..<4 { grid[row][col] = result[row] }
        }
    }
    
    private func mergeLine(_ line: [Int]) -> [Int] {
        var result: [Int] = []
        var skip = false
        for i in 0..<line.count {
            if skip { skip = false; continue }
            if i + 1 < line.count && line[i] == line[i + 1] {
                let merged = line[i] * 2
                result.append(merged)
                score += merged
                if merged >= 2048 && !hasWon {
                    hasWon = true
                    Haptics.playSuccess()
                }
                skip = true
            } else {
                result.append(line[i])
            }
        }
        return result
    }
    
    private func addRandomTile() {
        var emptyCells: [(Int, Int)] = []
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == 0 { emptyCells.append((r, c)) }
            }
        }
        guard let cell = emptyCells.randomElement() else { return }
        grid[cell.0][cell.1] = Bool.random() ? 2 : (Int.random(in: 0..<9) == 0 ? 4 : 2)
    }
    
    private func canMove() -> Bool {
        // Check empty cells
        for r in 0..<4 {
            for c in 0..<4 {
                if grid[r][c] == 0 { return true }
            }
        }
        // Check adjacent merges
        for r in 0..<4 {
            for c in 0..<4 {
                let val = grid[r][c]
                if c + 1 < 4 && grid[r][c + 1] == val { return true }
                if r + 1 < 4 && grid[r + 1][c] == val { return true }
            }
        }
        return false
    }
    
    private func saveBestScore() {
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
        }
    }
}
