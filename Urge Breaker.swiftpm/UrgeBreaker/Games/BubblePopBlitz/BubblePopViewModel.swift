import SwiftUI
import Combine

struct Bubble: Identifiable {
    let id = UUID()
    var position: CGPoint
    let word: String
    let isPositive: Bool
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    let size: CGFloat
    let speed: CGFloat
}

@MainActor
class BubblePopViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 30
    @Published var isGameOver: Bool = false
    @Published var bubbles: [Bubble] = []
    @Published var showCountdown: Bool = true
    @Published var countdownValue: Int = 2
    @Published var warningText: String = ""
    @Published var showSparkle: CGPoint? = nil
    
    var onComplete: (() -> Void)?
    private var gameTimer: AnyCancellable?
    private var spawnTimer: AnyCancellable?
    private var moveTimer: AnyCancellable?
    private var spawnInterval: TimeInterval = 1.2
    private var elapsedTime: TimeInterval = 0
    
    static let positiveWords = [
        "Strength", "Calm", "I've got this", "Breathe", "Present",
        "Focused", "Clear", "Resilient", "I choose me", "Steady",
        "Grounded", "Free", "Proud", "Strong", "Centered"
    ]
    
    static let cravingWords = [
        "Just once", "Give in", "No one knows", "Quick fix",
        "It's fine", "Not today", "Why not", "Just this time"
    ]
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        timeRemaining = 30
        isGameOver = false
        bubbles = []
        showCountdown = true
        countdownValue = 2
        elapsedTime = 0
        spawnInterval = 1.2
        
        // Countdown
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.countdownValue = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showCountdown = false
            self?.startGameTimers()
        }
    }
    
    private func startGameTimers() {
        // Game timer
        gameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.1
                    self.elapsedTime += 0.1
                    
                    // Escalate spawn rate
                    let progress = self.elapsedTime / 30.0
                    self.spawnInterval = max(0.6, 1.2 - (progress * 0.6))
                } else {
                    self.endGame()
                }
            }
        
        // Spawn timer
        spawnBubble()
        scheduleNextSpawn()
        
        // Move timer
        moveTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.moveBubbles()
            }
    }
    
    private func scheduleNextSpawn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + spawnInterval) { [weak self] in
            guard let self = self, !self.isGameOver else { return }
            self.spawnBubble()
            self.scheduleNextSpawn()
        }
    }
    
    private func spawnBubble() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let isPositive = Double.random(in: 0...1) > 0.35 // 65% positive
        let word: String
        if isPositive {
            word = Self.positiveWords.randomElement() ?? "Strength"
        } else {
            word = Self.cravingWords.randomElement() ?? "Give in"
        }
        
        let size = CGFloat.random(in: 70...100)
        let x = CGFloat.random(in: size...(screenWidth - size))
        
        let bubble = Bubble(
            position: CGPoint(x: x, y: screenHeight + size),
            word: word,
            isPositive: isPositive,
            size: size,
            speed: CGFloat.random(in: 1.5...3.0)
        )
        
        withAnimation {
            bubbles.append(bubble)
        }
    }
    
    private func moveBubbles() {
        for i in (0..<bubbles.count).reversed() {
            bubbles[i].position.y -= bubbles[i].speed
            
            // Remove if off screen
            if bubbles[i].position.y < -bubbles[i].size {
                bubbles.remove(at: i)
            }
        }
    }
    
    func tapBubble(_ bubble: Bubble) {
        guard !isGameOver else { return }
        
        if bubble.isPositive {
            score += 1
            Haptics.playLight()
            showSparkle = bubble.position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.showSparkle = nil
            }
        } else {
            score = max(0, score - 1)
            Haptics.playMedium()
            warningText = "Let them float away!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.warningText = ""
            }
        }
        
        withAnimation(.easeOut(duration: 0.2)) {
            bubbles.removeAll { $0.id == bubble.id }
        }
    }
    
    var completionMessage: String {
        if score >= 10 {
            return "Sharp focus! You stayed with the good stuff."
        } else {
            return "Good try! The positive ones are worth chasing."
        }
    }
    
    func endGame() {
        gameTimer?.cancel()
        spawnTimer?.cancel()
        moveTimer?.cancel()
        isGameOver = true
        
        withAnimation {
            bubbles = []
        }
        
        onComplete?()
    }
}
