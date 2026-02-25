import SwiftUI
import CoreMotion
import Combine

@MainActor
class ThunderJarViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var crackLevel: Double = 0 // 0-1
    @Published var isShattered: Bool = false
    @Published var shakeIntensity: Double = 0
    @Published var jarScale: CGFloat = 1.0
    @Published var showCompletion: Bool = false
    @Published var particles: [(id: UUID, x: CGFloat, y: CGFloat, opacity: Double)] = []
    
    private let motionManager = CMMotionManager()
    private var timer: AnyCancellable?
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        crackLevel = 0
        isShattered = false
        isGameOver = false
        showCompletion = false
        shakeIntensity = 0
        particles = []
        
        // Start accelerometer
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.05
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, _ in
                guard let self = self, let data = data, !self.isShattered else { return }
                
                let totalAccel = sqrt(data.acceleration.x * data.acceleration.x +
                                     data.acceleration.y * data.acceleration.y +
                                     data.acceleration.z * data.acceleration.z)
                
                let shakeThreshold = 1.5
                if totalAccel > shakeThreshold {
                    let intensity = min((totalAccel - shakeThreshold) / 2.0, 1.0)
                    Task { @MainActor in
                        self.shakeIntensity = intensity
                        self.crackLevel = min(self.crackLevel + intensity * 0.03, 1.0)
                        
                        // Escalating haptics
                        if self.crackLevel < 0.33 {
                            Haptics.playLight()
                        } else if self.crackLevel < 0.66 {
                            Haptics.playMedium()
                        } else {
                            Haptics.playHeavy()
                        }
                        
                        // Jar wobble
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
                            self.jarScale = CGFloat.random(in: 0.95...1.05)
                        }
                        
                        if self.crackLevel >= 1.0 {
                            self.shatter()
                        }
                    }
                } else {
                    Task { @MainActor in
                        self.shakeIntensity = 0
                        withAnimation { self.jarScale = 1.0 }
                    }
                }
            }
        } else {
            // Fallback: tap to crack
            startTapFallback()
        }
    }
    
    private func startTapFallback() {
        // For simulator / no accelerometer
    }
    
    func tapToShake() {
        guard !isShattered else { return }
        crackLevel = min(crackLevel + 0.15, 1.0)
        Haptics.playHeavy()
        withAnimation(.spring(response: 0.1, dampingFraction: 0.3)) {
            jarScale = 0.95
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            withAnimation { self?.jarScale = 1.0 }
        }
        if crackLevel >= 1.0 { shatter() }
    }
    
    private func shatter() {
        motionManager.stopAccelerometerUpdates()
        isShattered = true
        Haptics.playSuccess()
        score = 10
        
        // Create explosion particles
        for _ in 0..<20 {
            let p = (
                id: UUID(),
                x: CGFloat.random(in: -150...150),
                y: CGFloat.random(in: -200...100),
                opacity: 1.0
            )
            particles.append(p)
        }
        
        showCompletion = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.endGame()
        }
    }
    
    func endGame() {
        motionManager.stopAccelerometerUpdates()
        timer?.cancel()
        isGameOver = true
        onComplete?()
    }
}
