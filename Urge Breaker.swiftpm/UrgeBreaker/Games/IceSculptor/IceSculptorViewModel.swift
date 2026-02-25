import SwiftUI
import Combine

@MainActor
class IceSculptorViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var iceGrid: [[Bool]] = [] // true = ice still present
    @Published var revealProgress: Double = 0
    @Published var showCompletion: Bool = false
    @Published var particles: [(id: UUID, x: CGFloat, y: CGFloat, opacity: Double)] = []
    @Published var shapeName: String = ""
    
    private let gridSize = 12
    private var shapeGrid: [[Bool]] = [] // true = part of hidden shape
    private var totalShapePixels: Int = 0
    private var revealedPixels: Int = 0
    
    private let shapes: [(name: String, pattern: [(Int, Int)])] = [
        ("Star", [(6,1),(5,3),(3,4),(5,5),(4,7),(6,7),(7,5),(9,4),(7,3),(6,1),
                  (5,4),(6,3),(7,4),(6,5),(6,4)]),
        ("Heart", [(4,3),(3,4),(2,5),(2,6),(3,7),(4,8),(5,9),(6,10),(7,9),(8,8),
                   (9,7),(10,6),(10,5),(9,4),(8,3),(6,2),(5,3),(6,4),(7,3),
                   (4,5),(5,6),(6,7),(7,6),(8,5),(6,8),(5,7),(7,7)]),
        ("Diamond", [(6,2),(4,4),(3,6),(4,8),(6,10),(8,8),(9,6),(8,4),
                     (5,3),(5,5),(5,7),(5,9),(7,3),(7,5),(7,7),(7,9),(6,4),(6,6),(6,8)]),
    ]
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        isGameOver = false
        showCompletion = false
        revealedPixels = 0
        particles = []
        
        // Fill ice grid (all ice)
        iceGrid = Array(repeating: Array(repeating: true, count: gridSize), count: gridSize)
        
        // Pick a random shape
        let shape = shapes.randomElement() ?? shapes[0]
        shapeName = shape.name
        shapeGrid = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        
        for (row, col) in shape.pattern {
            if row < gridSize && col < gridSize {
                shapeGrid[row][col] = true
            }
        }
        totalShapePixels = shape.pattern.count
    }
    
    func chipIce(row: Int, col: Int) {
        guard row >= 0 && row < gridSize && col >= 0 && col < gridSize else { return }
        guard iceGrid[row][col] else { return }
        
        iceGrid[row][col] = false
        Haptics.playLight()
        
        // Check if this reveals a shape pixel
        if shapeGrid[row][col] {
            revealedPixels += 1
            score += 1
            revealProgress = Double(revealedPixels) / Double(max(totalShapePixels, 1))
        }
        
        // Check completion
        if revealProgress >= 0.85 {
            showCompletion = true
            Haptics.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                self?.endGame()
            }
        }
    }
    
    func chipArea(at point: CGPoint, cellSize: CGFloat) {
        let col = Int(point.x / cellSize)
        let row = Int(point.y / cellSize)
        
        // Chip a 2x2 area for easier carving
        for dr in -1...1 {
            for dc in -1...1 {
                chipIce(row: row + dr, col: col + dc)
            }
        }
    }
    
    func endGame() {
        isGameOver = true
        onComplete?()
    }
}
