import SwiftUI
import Combine

struct Star: Identifiable {
    let id = UUID()
    let position: CGPoint
    var isConnected: Bool = false
    var message: String
}

struct StarConnection: Identifiable {
    let id = UUID()
    let from: CGPoint
    let to: CGPoint
}

@MainActor
class ConstellationViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var stars: [Star] = []
    @Published var connections: [StarConnection] = []
    @Published var selectedStarIndex: Int? = nil
    @Published var dragLine: (CGPoint, CGPoint)? = nil
    @Published var currentMessage: String = ""
    @Published var showMessage: Bool = false
    @Published var showCompletion: Bool = false
    @Published var allConnected: Bool = false
    @Published var constellationName: String = ""
    
    private let affirmingMessages = [
        "Someone thought of you today",
        "You matter to someone right now",
        "Connection is always closer than it feels",
        "You are seen, even when it doesn't feel that way",
        "Someone out there is rooting for you",
        "Loneliness is a feeling, not a fact",
        "The people who love you haven't forgotten you",
        "Reaching out is an act of courage"
    ]
    
    // Pre-defined constellation layouts (normalized 0-1 coordinates)
    private let constellationLayouts: [(name: String, points: [(Double, Double)])] = [
        ("Heart", [(0.5, 0.2), (0.3, 0.35), (0.7, 0.35), (0.2, 0.55), (0.8, 0.55), (0.35, 0.75), (0.65, 0.75), (0.5, 0.9)]),
        ("Star", [(0.5, 0.15), (0.35, 0.45), (0.15, 0.45), (0.3, 0.65), (0.22, 0.9), (0.5, 0.75), (0.78, 0.9), (0.7, 0.65), (0.85, 0.45), (0.65, 0.45)]),
        ("Crescent", [(0.6, 0.15), (0.4, 0.3), (0.3, 0.5), (0.35, 0.7), (0.5, 0.85), (0.7, 0.8), (0.8, 0.6)]),
        ("Flower", [(0.5, 0.2), (0.35, 0.35), (0.65, 0.35), (0.25, 0.55), (0.75, 0.55), (0.5, 0.55), (0.5, 0.8)]),
        ("Hands", [(0.3, 0.3), (0.25, 0.5), (0.35, 0.65), (0.45, 0.5), (0.55, 0.5), (0.65, 0.65), (0.75, 0.5), (0.7, 0.3)])
    ]
    
    private var shuffledMessages: [String] = []
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        isGameOver = false
        showCompletion = false
        allConnected = false
        connections = []
        selectedStarIndex = nil
        dragLine = nil
        currentMessage = ""
        showMessage = false
        
        shuffledMessages = affirmingMessages.shuffled()
        
        // Pick a random constellation
        let layout = constellationLayouts.randomElement() ?? constellationLayouts[0]
        constellationName = layout.name
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let gameAreaWidth = screenWidth - 80
        let gameAreaHeight = screenHeight * 0.5
        let offsetX: CGFloat = 40
        let offsetY: CGFloat = screenHeight * 0.2
        
        stars = layout.points.enumerated().map { index, point in
            Star(
                position: CGPoint(
                    x: offsetX + CGFloat(point.0) * gameAreaWidth,
                    y: offsetY + CGFloat(point.1) * gameAreaHeight
                ),
                message: shuffledMessages[index % shuffledMessages.count]
            )
        }
    }
    
    func selectStar(at index: Int) {
        guard !stars[index].isConnected || selectedStarIndex != nil else { return }
        
        if selectedStarIndex == nil {
            selectedStarIndex = index
        } else if let fromIndex = selectedStarIndex, fromIndex != index {
            // Make connection
            let from = stars[fromIndex].position
            let to = stars[index].position
            
            connections.append(StarConnection(from: from, to: to))
            stars[fromIndex].isConnected = true
            stars[index].isConnected = true
            
            Haptics.playLight()
            
            // Show affirming message
            currentMessage = stars[index].message
            showMessage = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                withAnimation { self?.showMessage = false }
            }
            
            selectedStarIndex = nil
            dragLine = nil
            
            // Check if all connected
            if stars.allSatisfy({ $0.isConnected }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.allConnected = true
                    Haptics.playSuccess()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
                        self?.showCompletion = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                            self?.endGame()
                        }
                    }
                }
            }
        }
    }
    
    func updateDrag(to point: CGPoint) {
        guard let fromIndex = selectedStarIndex else { return }
        dragLine = (stars[fromIndex].position, point)
    }
    
    func cancelDrag() {
        selectedStarIndex = nil
        dragLine = nil
    }
    
    func nearestStar(to point: CGPoint, threshold: CGFloat = 40) -> Int? {
        for (index, star) in stars.enumerated() {
            let dx = star.position.x - point.x
            let dy = star.position.y - point.y
            if sqrt(dx * dx + dy * dy) < threshold {
                return index
            }
        }
        return nil
    }
    
    func endGame() {
        isGameOver = true
        onComplete?()
    }
}
