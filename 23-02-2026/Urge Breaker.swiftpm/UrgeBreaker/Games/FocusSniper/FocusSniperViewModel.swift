import SwiftUI
import Combine

@MainActor
class FocusSniperViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 30
    @Published var isGameOver: Bool = false
    @Published var targets: [FocusTarget] = []
    
    var onComplete: (() -> Void)?
    private var timer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        timeRemaining = 30
        isGameOver = false
        targets = []
        
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.updateTime()
                self.moveTargets()
            }
            
        spawnTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.spawnTarget()
            }
    }
    
    private func updateTime() {
        if timeRemaining > 0 {
            timeRemaining -= 0.1
        } else {
            endGame()
        }
    }
    
    private func spawnTarget() {
        guard !isGameOver else { return }
        
        let screen = UIScreen.main.bounds
        let size = CGFloat.random(in: 60...100)
        let x = CGFloat.random(in: size...(screen.width - size))
        let y = CGFloat.random(in: 150...(screen.height - 200))
        
        let type: TargetType = Double.random(in: 0...1) > 0.3 ? .correct : .trap
        
        let target = FocusTarget(
            position: CGPoint(x: x, y: y),
            size: size,
            type: type
        )
        
        withAnimation {
            targets.append(target)
        }
        
        // Auto remove target after some time
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.targets.removeAll { $0.id == target.id }
            }
        }
    }
    
    private func moveTargets() {
        // Subtle drift
        for i in 0..<targets.count {
            targets[i].position.x += CGFloat.random(in: -2...2)
            targets[i].position.y += CGFloat.random(in: -2...2)
        }
    }
    
    func tapTarget(_ target: FocusTarget) {
        guard !isGameOver else { return }
        
        if target.type == .correct {
            score += 10
            Haptics.playLight()
        } else {
            score = max(0, score - 20)
            Haptics.playHeavy()
        }
        
        withAnimation {
            targets.removeAll { $0.id == target.id }
        }
    }
    
    func endGame() {
        timer?.cancel()
        spawnTimer?.cancel()
        isGameOver = true
        onComplete?()
    }
}
