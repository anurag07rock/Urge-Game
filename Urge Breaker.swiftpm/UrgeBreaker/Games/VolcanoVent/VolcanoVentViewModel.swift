import SwiftUI
import Combine

@MainActor
class VolcanoVentViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 90
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var pressure: Double = 0.0 // 0 to 1
    @Published var isHolding: Bool = false
    @Published var eruptionCount: Int = 0
    @Published var isErupting: Bool = false
    @Published var isOverflow: Bool = false
    @Published var showCompletion: Bool = false
    @Published var particles: [LavaParticle] = []
    
    private var holdTimer: AnyCancellable?
    private var gameTimer: AnyCancellable?
    private let requiredEruptions = 3
    private let fillDuration: Double = 2.5 // seconds to fill
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        timeRemaining = 90
        isGameOver = false
        eruptionCount = 0
        pressure = 0
        isHolding = false
        isErupting = false
        isOverflow = false
        showCompletion = false
        particles = []
        
        gameTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
    }
    
    func startHolding() {
        guard !isErupting && !isGameOver && !showCompletion else { return }
        isHolding = true
        pressure = 0
        isOverflow = false
        
        holdTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isHolding else { return }
                let increment = 0.05 / self.fillDuration
                self.pressure = min(self.pressure + increment, 1.2) // Allow overflow past 1.0
                
                // Escalating haptics
                if self.pressure < 0.33 {
                    Haptics.playLight()
                } else if self.pressure < 0.66 {
                    Haptics.playMedium()
                } else {
                    Haptics.playHeavy()
                }
                
                // Overflow auto-eruption
                if self.pressure >= 1.15 {
                    self.isOverflow = true
                    self.triggerEruption()
                }
            }
    }
    
    func stopHolding() {
        guard isHolding else { return }
        isHolding = false
        holdTimer?.cancel()
        holdTimer = nil
        
        if pressure >= 0.95 {
            triggerEruption()
        } else {
            // Not enough pressure — reset
            withAnimation(.easeOut(duration: 0.3)) {
                pressure = 0
            }
        }
    }
    
    private func triggerEruption() {
        isHolding = false
        holdTimer?.cancel()
        holdTimer = nil
        isErupting = true
        
        Haptics.playSuccess()
        eruptionCount += 1
        score += 10
        
        // Create particles
        createLavaParticles()
        
        // Reset after eruption animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.isErupting = false
            self.isOverflow = false
            
            withAnimation(.easeOut(duration: 0.5)) {
                self.pressure = 0
                self.particles = []
            }
            
            if self.eruptionCount >= self.requiredEruptions {
                self.showCompletion = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    self?.endGame()
                }
            }
        }
    }
    
    private func createLavaParticles() {
        let colors: [Color] = [
            Color(red: 1.0, green: 0.4, blue: 0.1),
            Color(red: 1.0, green: 0.6, blue: 0.0),
            Color(red: 1.0, green: 0.2, blue: 0.0),
            .yellow, .orange
        ]
        
        for _ in 0..<15 {
            let particle = LavaParticle(
                position: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.35),
                color: colors.randomElement() ?? .orange,
                size: CGFloat.random(in: 8...24),
                opacity: 1.0
            )
            particles.append(particle)
        }
        
        // Animate particles outward
        for i in 0..<particles.count {
            let angle = Double.random(in: -Double.pi * 0.8 ... -Double.pi * 0.2)
            let distance = Double.random(in: 80...250)
            withAnimation(.easeOut(duration: 1.2)) {
                particles[i].position.x += CGFloat(cos(angle) * distance)
                particles[i].position.y += CGFloat(sin(angle) * distance)
                particles[i].opacity = 0
            }
        }
    }
    
    func endGame() {
        gameTimer?.cancel()
        holdTimer?.cancel()
        isGameOver = true
        onComplete?()
    }
}

struct LavaParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var opacity: Double
}
