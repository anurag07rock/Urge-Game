import SwiftUI
import Combine

struct EmotionOrb: Identifiable {
    let id = UUID()
    var position: CGPoint
    let emotion: String
    let color: Color
    var isMerged: Bool = false
}

@MainActor
class MoodMixerViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = 60
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var orbs: [EmotionOrb] = []
    @Published var mergedColor: Color = .clear
    @Published var mergedEmotion: String = ""
    @Published var showSignature: Bool = false
    @Published var showCompletion: Bool = false
    @Published var draggedOrbId: UUID? = nil
    
    private let emotionSets: [[(String, Color)]] = [
        [("Calm", .blue), ("Joy", .yellow), ("Hope", .green)],
        [("Strength", .red), ("Peace", .cyan), ("Focus", .purple)],
        [("Warmth", .orange), ("Clarity", .mint), ("Courage", .pink)],
        [("Balance", .teal), ("Love", .red), ("Growth", .green)],
    ]
    
    private let signatures = [
        "Resilient Spirit", "Quiet Strength", "Warm Focus",
        "Peaceful Energy", "Clear Vision", "Inner Fire",
        "Gentle Power", "Calm Courage", "Bright Horizon"
    ]
    
    init(onComplete: (() -> Void)?) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        score = 0
        isGameOver = false
        showSignature = false
        showCompletion = false
        mergedColor = .clear
        mergedEmotion = ""
        
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        
        let emotions = emotionSets.randomElement() ?? emotionSets[0]
        orbs = emotions.enumerated().map { i, e in
            EmotionOrb(
                position: CGPoint(
                    x: CGFloat.random(in: 80...(screenW - 80)),
                    y: screenH * 0.3 + CGFloat(i) * 120
                ),
                emotion: e.0,
                color: e.1
            )
        }
    }
    
    func moveOrb(id: UUID, to position: CGPoint) {
        guard let index = orbs.firstIndex(where: { $0.id == id }) else { return }
        orbs[index].position = position
        
        // Check proximity to other orbs
        checkMerge()
    }
    
    private func checkMerge() {
        let activeOrbs = orbs.filter { !$0.isMerged }
        guard activeOrbs.count >= 2 else { return }
        
        for i in 0..<activeOrbs.count {
            for j in (i+1)..<activeOrbs.count {
                let dx = activeOrbs[i].position.x - activeOrbs[j].position.x
                let dy = activeOrbs[i].position.y - activeOrbs[j].position.y
                let dist = sqrt(dx * dx + dy * dy)
                
                if dist < 60 {
                    // Merge!
                    Haptics.playLight()
                    
                    if let idx1 = orbs.firstIndex(where: { $0.id == activeOrbs[i].id }) {
                        orbs[idx1].isMerged = true
                    }
                    if let idx2 = orbs.firstIndex(where: { $0.id == activeOrbs[j].id }) {
                        orbs[idx2].isMerged = true
                    }
                    
                    // Check if all merged
                    if orbs.filter({ !$0.isMerged }).count <= 1 {
                        completeBlend()
                    }
                    return
                }
            }
        }
    }
    
    private func completeBlend() {
        // Mark remaining orb as merged too
        for i in 0..<orbs.count {
            orbs[i].isMerged = true
        }
        
        // Create blended result
        let colors = orbs.map { $0.color }
        mergedColor = colors.first ?? .purple
        mergedEmotion = signatures.randomElement() ?? "Inner Balance"
        score = 10
        
        Haptics.playSuccess()
        
        withAnimation(.spring(response: 0.5)) {
            showSignature = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.showCompletion = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.endGame()
            }
        }
    }
    
    func endGame() {
        isGameOver = true
        onComplete?()
    }
}
