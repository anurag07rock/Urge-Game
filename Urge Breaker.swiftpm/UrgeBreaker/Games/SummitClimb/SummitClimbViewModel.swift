import SwiftUI
import CoreMotion
import Combine

@MainActor
class SummitClimbViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 90
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var altitude: CGFloat = 0 // 0-1
    @Published var tilt: CGFloat = 0 // -1 to 1
    @Published var isSlipping: Bool = false
    @Published var windResistance: Double = 0
    @Published var showCompletion: Bool = false
    @Published var climberOffset: CGFloat = 0
    
    private let motionManager = CMMotionManager()
    private var climbTimer: AnyCancellable?
    private var tiltThreshold: Double = 0.15
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        altitude = 0
        tilt = 0
        isSlipping = false
        isGameOver = false
        showCompletion = false
        score = 0
        climberOffset = 0
        
        // Start gyroscope
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.05
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                guard let self = self, let motion = motion, !self.showCompletion else { return }
                
                Task { @MainActor in
                    let pitch = motion.attitude.pitch
                    let roll = motion.attitude.roll
                    let totalTilt = sqrt(pitch * pitch + roll * roll)
                    
                    self.tilt = CGFloat(max(-1, min(1, roll * 3)))
                    self.windResistance = min(totalTilt * 2, 1.0)
                    
                    if totalTilt > self.tiltThreshold {
                        self.isSlipping = true
                        withAnimation(.spring(response: 0.2)) {
                            self.altitude = max(0, self.altitude - 0.005)
                            self.climberOffset = self.tilt * 30
                        }
                        if Int(self.altitude * 1000) % 20 == 0 {
                            Haptics.playLight()
                        }
                    } else {
                        self.isSlipping = false
                        withAnimation(.spring(response: 0.3)) {
                            self.altitude = min(1.0, self.altitude + 0.003)
                            self.climberOffset = 0
                        }
                    }
                    
                    if self.altitude >= 1.0 {
                        self.reachSummit()
                    }
                }
            }
        } else {
            // Fallback: auto-climb with tap to counter "wind"
            startTapFallback()
        }
    }
    
    private func startTapFallback() {
        climbTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.showCompletion else { return }
                withAnimation {
                    self.altitude = min(1.0, self.altitude + 0.002)
                }
                if self.altitude >= 1.0 { self.reachSummit() }
            }
    }
    
    func tapToSteady() {
        guard !showCompletion else { return }
        Haptics.playLight()
        withAnimation(.spring(response: 0.2)) {
            altitude = min(1.0, altitude + 0.01)
            climberOffset = 0
        }
    }
    
    private func reachSummit() {
        motionManager.stopDeviceMotionUpdates()
        climbTimer?.cancel()
        showCompletion = true
        score = 10
        Haptics.playSuccess()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.endGame()
        }
    }
    
    func endGame() {
        motionManager.stopDeviceMotionUpdates()
        climbTimer?.cancel()
        isGameOver = true
        onComplete?()
    }
}
