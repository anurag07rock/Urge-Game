import SwiftUI
import Combine

@MainActor
class StressSmashViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = Constants.gameDuration
    @Published var isGameOver: Bool = false
    @Published var buttonScale: CGFloat = 1.0
    @Published var isSmashing: Bool = false
    @Published var shards: [StressSmashShard] = []
    
    var onComplete: (() -> Void)?
    private var timer: AnyCancellable?
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        timeRemaining = Constants.gameDuration
        isGameOver = false
        shards = []
        
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
    }
    
    func smash() {
        guard !isGameOver else { return }
        
        score += 1
        Haptics.playHeavy()
        
        // Animation
        isSmashing = true
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
            buttonScale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                self?.buttonScale = 1.0
                self?.isSmashing = false
            }
        }
        
        // Create shards
        createShards()
    }
    
    private func createShards() {
        let icons = ["plus.diamond.fill", "hexagon.fill", "square.fill", "triangle.fill"]
        for _ in 0...5 {
            let shard = StressSmashShard(
                position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2),
                icon: icons.randomElement()!,
                size: CGFloat.random(in: 10...30),
                color: [.ubPrimary, .ubAccent, .white].randomElement()!,
                opacity: 1.0
            )
            shards.append(shard)
            
            // Animate shard
            let index = shards.count - 1
            let angle = Double.random(in: 0...Double.pi * 2)
            let distance = Double.random(in: 100...300)
            
            withAnimation(.easeOut(duration: 0.8)) {
                shards[index].position.x += CGFloat(cos(angle) * distance)
                shards[index].position.y += CGFloat(sin(angle) * distance)
                shards[index].opacity = 0
            }
        }
        
        // Clean up old shards to prevent unbounded growth
        if shards.count > 30 {
            shards.removeFirst(15)
        }
    }
    
    func endGame() {
        timer?.cancel()
        isGameOver = true
        onComplete?()
    }
}
