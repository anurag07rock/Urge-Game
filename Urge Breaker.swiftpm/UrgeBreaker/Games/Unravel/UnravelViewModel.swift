import SwiftUI
import Combine

@MainActor
class UnravelViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 90
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var layers: Int = 5
    @Published var currentLayer: Int = 0
    @Published var loopProgress: CGFloat = 0 // 0-1 per loop
    @Published var threadAngle: CGFloat = 0
    @Published var showCompletion: Bool = false
    @Published var yarnRadius: CGFloat = 100
    @Published var glowIntensity: Double = 0.3
    
    private var dragStartAngle: CGFloat = 0
    private var totalAngleDragged: CGFloat = 0
    private let anglePerLoop: CGFloat = 360 * 1.5 // 1.5 full rotations per layer
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        isGameOver = false
        showCompletion = false
        currentLayer = 0
        loopProgress = 0
        threadAngle = 0
        yarnRadius = 100
        glowIntensity = 0.3
        totalAngleDragged = 0
    }
    
    func updateDrag(at point: CGPoint, center: CGPoint) {
        guard !showCompletion else { return }
        
        let dx = point.x - center.x
        let dy = point.y - center.y
        let angle = atan2(dy, dx) * 180 / .pi
        
        let angleDiff = angle - threadAngle
        
        // Only count forward movement (clockwise)
        if abs(angleDiff) < 30 || abs(angleDiff) > 330 {
            totalAngleDragged += abs(angleDiff)
            threadAngle = angle
            loopProgress = min(totalAngleDragged / anglePerLoop, 1.0)
            
            if Int(totalAngleDragged) % 60 == 0 {
                Haptics.playSelection()
            }
            
            if loopProgress >= 1.0 {
                completeLoop()
            }
        }
    }
    
    private func completeLoop() {
        currentLayer += 1
        totalAngleDragged = 0
        loopProgress = 0
        score += 2
        Haptics.playLight()
        
        withAnimation(.spring(response: 0.5)) {
            yarnRadius = max(30, 100 - CGFloat(currentLayer) * 14)
            glowIntensity = 0.3 + Double(currentLayer) * 0.15
        }
        
        if currentLayer >= layers {
            showCompletion = true
            Haptics.playSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.endGame()
            }
        }
    }
    
    func endGame() {
        isGameOver = true
        onComplete?()
    }
}
