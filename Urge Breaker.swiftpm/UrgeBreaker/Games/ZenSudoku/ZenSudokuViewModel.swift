import SwiftUI

// MARK: - Zen Sudoku ViewModel (4×4, digits 1–4)
@MainActor
class ZenSudokuViewModel: ObservableObject {
    
    struct Cell: Identifiable {
        let id: Int // 0–15
        var value: Int // 0 = empty
        let isFixed: Bool
        var hasError: Bool = false
        
        var row: Int { id / 4 }
        var col: Int { id % 4 }
        var box: Int { (row / 2) * 2 + (col / 2) }
    }
    
    @Published var cells: [Cell] = []
    @Published var selectedCellIndex: Int? = nil
    @Published var isComplete: Bool = false
    @Published var moveCount: Int = 0
    
    var onComplete: (() -> Void)?
    
    // Pre-defined puzzle templates: (solution, puzzle with blanks)
    // Each is a 16-element array representing a 4×4 grid
    private static let templates: [([Int], [Int])] = [
        // Template 1
        ([1,2,3,4, 3,4,1,2, 2,3,4,1, 4,1,2,3],
         [1,0,3,0, 0,4,0,2, 2,0,4,0, 0,1,0,3]),
        // Template 2
        ([2,1,4,3, 4,3,2,1, 1,4,3,2, 3,2,1,4],
         [0,1,0,3, 4,0,2,0, 0,4,0,2, 3,0,1,0]),
        // Template 3
        ([3,4,1,2, 1,2,3,4, 4,1,2,3, 2,3,4,1],
         [3,0,1,0, 0,2,0,4, 4,0,2,0, 0,3,0,1]),
        // Template 4
        ([4,3,2,1, 2,1,4,3, 3,4,1,2, 1,2,3,4],
         [0,3,0,1, 2,0,4,0, 0,4,0,2, 1,0,3,0]),
        // Template 5
        ([1,3,2,4, 4,2,1,3, 3,1,4,2, 2,4,3,1],
         [0,3,2,0, 4,0,0,3, 3,0,0,2, 0,4,3,0]),
    ]
    
    private var solution: [Int] = []
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
        loadPuzzle()
    }
    
    func loadPuzzle() {
        let template = ZenSudokuViewModel.templates.randomElement()!
        solution = template.0
        let puzzle = template.1
        
        cells = (0..<16).map { i in
            Cell(id: i, value: puzzle[i], isFixed: puzzle[i] != 0)
        }
        selectedCellIndex = nil
        isComplete = false
        moveCount = 0
    }
    
    func selectCell(_ index: Int) {
        guard index >= 0 && index < 16 else { return }
        guard !cells[index].isFixed else { return }
        selectedCellIndex = index
    }
    
    func placeNumber(_ number: Int) {
        guard let idx = selectedCellIndex, !cells[idx].isFixed else { return }
        
        cells[idx].value = number
        moveCount += 1
        validateAll()
        checkCompletion()
    }
    
    func clearCell() {
        guard let idx = selectedCellIndex, !cells[idx].isFixed else { return }
        cells[idx].value = 0
        cells[idx].hasError = false
        validateAll()
    }
    
    func reset() {
        loadPuzzle()
    }
    
    // MARK: - Validation
    
    private func validateAll() {
        // Reset errors
        for i in 0..<cells.count {
            cells[i].hasError = false
        }
        
        // Check rows
        for row in 0..<4 {
            let indices = (0..<4).map { row * 4 + $0 }
            markDuplicates(in: indices)
        }
        
        // Check columns
        for col in 0..<4 {
            let indices = (0..<4).map { $0 * 4 + col }
            markDuplicates(in: indices)
        }
        
        // Check 2×2 boxes
        for boxRow in stride(from: 0, to: 4, by: 2) {
            for boxCol in stride(from: 0, to: 4, by: 2) {
                let indices = [
                    boxRow * 4 + boxCol,
                    boxRow * 4 + boxCol + 1,
                    (boxRow + 1) * 4 + boxCol,
                    (boxRow + 1) * 4 + boxCol + 1
                ]
                markDuplicates(in: indices)
            }
        }
    }
    
    private func markDuplicates(in indices: [Int]) {
        var seen: [Int: [Int]] = [:]
        for idx in indices {
            let v = cells[idx].value
            if v != 0 {
                seen[v, default: []].append(idx)
            }
        }
        for (_, idxs) in seen where idxs.count > 1 {
            for idx in idxs {
                cells[idx].hasError = true
            }
        }
    }
    
    private func checkCompletion() {
        let allFilled = cells.allSatisfy { $0.value != 0 }
        let noErrors = cells.allSatisfy { !$0.hasError }
        
        if allFilled && noErrors {
            isComplete = true
            Haptics.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.onComplete?()
            }
        }
    }
}
