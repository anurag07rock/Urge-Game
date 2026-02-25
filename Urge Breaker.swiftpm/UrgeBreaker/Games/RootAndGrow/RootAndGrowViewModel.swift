import SwiftUI
import Combine

@MainActor
class RootAndGrowViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var treeHeight: CGFloat = 0 // 0-1
    @Published var rootDepth: CGFloat = 0 // 0-1
    @Published var branches: [(angle: Double, length: CGFloat, level: Int)] = []
    @Published var roots: [(angle: Double, length: CGFloat)] = []
    @Published var tapCount: Int = 0
    @Published var showCompletion: Bool = false
    @Published var leafParticles: [(id: UUID, x: CGFloat, y: CGFloat, opacity: Double)] = []
    
    private let maxTaps = 20
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        isGameOver = false
        showCompletion = false
        treeHeight = 0.05
        rootDepth = 0.05
        branches = []
        roots = []
        tapCount = 0
        leafParticles = []
    }
    
    func tap() {
        guard !showCompletion && !isGameOver else { return }
        tapCount += 1
        Haptics.playLight()
        
        let progress = Double(tapCount) / Double(maxTaps)
        
        // Alternate between roots and branches
        if tapCount % 2 == 1 {
            // Grow roots
            withAnimation(.spring(response: 0.4)) {
                rootDepth = min(CGFloat(progress), 1.0)
                let angle = Double.random(in: 150...210) // Downward angles
                roots.append((angle: angle, length: CGFloat.random(in: 20...50)))
            }
        } else {
            // Grow branches
            withAnimation(.spring(response: 0.4)) {
                treeHeight = min(CGFloat(progress), 1.0)
                let angle = Double.random(in: -60...60) // Upward angles
                let level = branches.count / 2
                branches.append((angle: angle, length: CGFloat.random(in: 25...60), level: level))
            }
            
            // Add leaf particles every 4 taps
            if tapCount % 4 == 0 {
                addLeaves()
            }
        }
        
        score = tapCount
        
        if tapCount >= maxTaps {
            showCompletion = true
            Haptics.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.endGame()
            }
        }
    }
    
    private func addLeaves() {
        let screenW = UIScreen.main.bounds.width
        for _ in 0..<3 {
            leafParticles.append((
                id: UUID(),
                x: screenW / 2 + CGFloat.random(in: -80...80),
                y: UIScreen.main.bounds.height * 0.3 + CGFloat.random(in: -40...40),
                opacity: 1.0
            ))
        }
    }
    
    func endGame() {
        isGameOver = true
        onComplete?()
    }
}
