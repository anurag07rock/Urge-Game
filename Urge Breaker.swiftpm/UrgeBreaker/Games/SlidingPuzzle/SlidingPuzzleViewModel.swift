import SwiftUI

// MARK: - Sliding Puzzle ViewModel (3×3 – 8 Puzzle)
@MainActor
class SlidingPuzzleViewModel: ObservableObject {
    
    @Published var tiles: [Int] = [] // 0 = empty space, 1–8 = numbered tiles
    @Published var moveCount: Int = 0
    @Published var isSolved: Bool = false
    
    let gridSize = 3
    var onComplete: (() -> Void)?
    
    private let goalState = [1, 2, 3, 4, 5, 6, 7, 8, 0]
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        startNewGame()
    }
    
    func startNewGame() {
        tiles = generateSolvablePuzzle()
        moveCount = 0
        isSolved = false
    }
    
    func tapTile(at index: Int) {
        guard !isSolved else { return }
        guard let emptyIndex = tiles.firstIndex(of: 0) else { return }
        
        // Check if the tapped tile is adjacent to the empty space
        let tappedRow = index / gridSize
        let tappedCol = index % gridSize
        let emptyRow = emptyIndex / gridSize
        let emptyCol = emptyIndex % gridSize
        
        let isAdjacent = (abs(tappedRow - emptyRow) + abs(tappedCol - emptyCol)) == 1
        
        guard isAdjacent else { return }
        
        // Swap
        tiles.swapAt(index, emptyIndex)
        moveCount += 1
        
        Haptics.playSelection()
        
        // Check win
        if tiles == goalState {
            isSolved = true
            Haptics.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.onComplete?()
            }
        }
    }
    
    // MARK: - Solvable Puzzle Generation
    
    /// Generates a solvable 8-puzzle by shuffling from the solved state
    private func generateSolvablePuzzle() -> [Int] {
        var state = goalState
        var emptyIndex = 8 // Position of 0 in goal state
        
        // Perform random valid moves to shuffle
        let shuffleMoves = 200
        for _ in 0..<shuffleMoves {
            let neighbors = adjacentIndices(of: emptyIndex)
            if let randomNeighbor = neighbors.randomElement() {
                state.swapAt(emptyIndex, randomNeighbor)
                emptyIndex = randomNeighbor
            }
        }
        
        // Make sure we didn't end up at the solved state
        if state == goalState {
            // Do a few more moves
            for _ in 0..<10 {
                let neighbors = adjacentIndices(of: emptyIndex)
                if let randomNeighbor = neighbors.randomElement() {
                    state.swapAt(emptyIndex, randomNeighbor)
                    emptyIndex = randomNeighbor
                }
            }
        }
        
        return state
    }
    
    private func adjacentIndices(of index: Int) -> [Int] {
        let row = index / gridSize
        let col = index % gridSize
        var neighbors: [Int] = []
        
        if row > 0 { neighbors.append((row - 1) * gridSize + col) }
        if row < gridSize - 1 { neighbors.append((row + 1) * gridSize + col) }
        if col > 0 { neighbors.append(row * gridSize + (col - 1)) }
        if col < gridSize - 1 { neighbors.append(row * gridSize + (col + 1)) }
        
        return neighbors
    }
}
