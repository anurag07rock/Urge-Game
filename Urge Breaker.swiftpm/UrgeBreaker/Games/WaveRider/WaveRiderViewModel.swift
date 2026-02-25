import SwiftUI
import Combine

@MainActor
class WaveRiderViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var waveOffset: CGFloat = 0
    @Published var breathRingScale: CGFloat = 0.5
    @Published var isInhaling: Bool = true
    @Published var playerY: CGFloat = 0.5 // 0-1 normalized
    @Published var perfectCycles: Int = 0
    @Published var syncScore: Double = 0
    @Published var showCompletion: Bool = false
    @Published var feedback: String = ""
    
    private var timer: AnyCancellable?
    private var breathTimer: AnyCancellable?
    private var elapsed: Double = 0
    private let breathCycleDuration: Double = 6.0 // 3s inhale + 3s exhale
    private let requiredCycles = 3
    private var currentCycleSync: Double = 0
    private var syncSamples: Int = 0
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        perfectCycles = 0
        isGameOver = false
        showCompletion = false
        elapsed = 0
        playerY = 0.5
        waveOffset = 0
        currentCycleSync = 0
        syncSamples = 0
        
        timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsed += 0.03
                
                // Animate wave
                self.waveOffset += 2
                
                // Breathing ring cycle
                let cycleProgress = self.elapsed.truncatingRemainder(dividingBy: self.breathCycleDuration)
                let halfCycle = self.breathCycleDuration / 2
                
                if cycleProgress < halfCycle {
                    self.isInhaling = true
                    self.breathRingScale = 0.5 + CGFloat(cycleProgress / halfCycle) * 0.5
                } else {
                    self.isInhaling = false
                    self.breathRingScale = 1.0 - CGFloat((cycleProgress - halfCycle) / halfCycle) * 0.5
                }
                
                // Check sync
                let targetY = 1.0 - Double(self.breathRingScale) // Inverted: scale up = swipe up
                let diff = abs(Double(self.playerY) - targetY)
                self.syncScore = max(0, 1.0 - diff * 2.5)
                self.currentCycleSync += self.syncScore
                self.syncSamples += 1
                
                // Check cycle completion
                if cycleProgress < 0.05 && self.elapsed > 1.0 && self.syncSamples > 50 {
                    let avgSync = self.currentCycleSync / Double(self.syncSamples)
                    if avgSync > 0.6 {
                        self.perfectCycles += 1
                        self.score += 10
                        Haptics.playSuccess()
                        self.feedback = "Perfect ride! 🌊"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                            self?.feedback = ""
                        }
                    }
                    self.currentCycleSync = 0
                    self.syncSamples = 0
                    
                    if self.perfectCycles >= self.requiredCycles {
                        self.showCompletion = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                            self?.endGame()
                        }
                    }
                }
            }
    }
    
    func updateSwipe(_ y: CGFloat, in height: CGFloat) {
        playerY = max(0, min(1, y / height))
    }
    
    func endGame() {
        timer?.cancel()
        isGameOver = true
        onComplete?()
    }
}
