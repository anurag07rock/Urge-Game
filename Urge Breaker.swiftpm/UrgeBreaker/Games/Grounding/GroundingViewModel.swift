import SwiftUI
import Combine

@MainActor
class GroundingViewModel: BaseGameViewModel {
    @Published var score: Int = 0
    @Published var timeRemaining: TimeInterval = Constants.gameDuration
    @Published var isGameOver: Bool = false
    var onComplete: (() -> Void)?
    
    @Published var currentStageIndex: Int = 0
    
    struct GroundingStage {
        let title: String
        let prompts: [String] // e.g., ["Item 1", "Item 2", ...] to count down
        let count: Int
        let icon: String // SF Symbol
    }
    
    let stages: [GroundingStage] = [
        GroundingStage(title: "5 Things You See", prompts: [], count: 5, icon: "eye"),
        GroundingStage(title: "4 Things You Feel", prompts: [], count: 4, icon: "hand.raised"),
        GroundingStage(title: "3 Things You Hear", prompts: [], count: 3, icon: "ear"),
        GroundingStage(title: "2 Things You Smell", prompts: [], count: 2, icon: "nose"),
        GroundingStage(title: "1 Thing You're Grateful For", prompts: [], count: 1, icon: "heart")
    ]
    
    @Published var currentItemCount: Int = 1 // Track which item within the stage we are on (1 of 5, 2 of 5...)
    
    private var timer: AnyCancellable?
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    func startGame() {
        isGameOver = false
        timeRemaining = Constants.gameDuration
        score = 0
        currentStageIndex = 0
        currentItemCount = 1
        
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in // MainActor ensures self is handled on main thread
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
    }
    
    func confirmItem() {
        Haptics.playLight()
        score += 10
        
        let stage = stages[currentStageIndex]
        
        if currentItemCount < stage.count {
            currentItemCount += 1
        } else {
            // Stage Complete
            Haptics.playSuccess()
            nextStage()
        }
    }
    
    func nextStage() {
        if currentStageIndex < stages.count - 1 {
            currentStageIndex += 1
            currentItemCount = 1
        } else {
            // All stages done
            endGame()
        }
    }
    
    func endGame() {
        timer?.cancel()
        timer = nil
        isGameOver = true
        onComplete?()
    }
}
