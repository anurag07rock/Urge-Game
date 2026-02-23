import SwiftUI
import Combine

@MainActor
class GameSessionViewModel: ObservableObject {
    enum State {
        case preCheck
        case instructions
        case playing
        case postCheck
        case summary
    }
    
    @Published var currentState: State = .preCheck
    @Published var intensity: Double = 3.0 // 1-5
    @Published var selectedTrigger: Trigger?
    @Published var selectedGame: GameType?
    @Published var session: UrgeSession?
    @Published var reward: Reward?
    
    @Published var appreciationMessage: String = ""
    
    private let urgeService: UrgeService
    
    init(urgeService: UrgeService) {
        self.urgeService = urgeService
    }
    
    func startSession() {
        // Adaptive Suggestions based on Trigger
        if let trigger = selectedTrigger {
            switch trigger {
            case .stress:
                selectedGame = .stressSmash
            case .boredom:
                selectedGame = .memoryPuzzle
            case .loneliness:
                selectedGame = .breathing
            case .habit:
                selectedGame = .focusSniper
            }
        } else {
            // Default intensity-based selection
            switch Int(intensity) {
            case 1:
                selectedGame = .breathing
            case 2:
                selectedGame = .rhythmPulse
            case 3:
                selectedGame = .focusSniper
            case 4:
                selectedGame = .stressSmash
            case 5:
                selectedGame = .focusHold
            default:
                selectedGame = .breathing
            }
        }
        
        var newSession = urgeService.createSession(gameType: selectedGame!, intensity: Int(intensity))
        newSession.trigger = selectedTrigger
        self.session = newSession
        
        // Phase 3: Auto-Shielding
        if urgeService.currentUser.focusShieldEnabled {
            FocusService.shared.startShielding()
        }
        
        withAnimation {
            currentState = .instructions
        }
    }
    
    func startGameConfirmed() {
        withAnimation {
            currentState = .playing
        }
    }
    
    func playAgain() {
        // Reset state but keep intensity
        startSession()
    }
    
    func gameCompleted() {
        appreciationMessage = AppreciationMessageProvider.getRandomMessage()
        withAnimation {
            currentState = .postCheck
        }
    }
    
    func completeSession(intensityAfter: Int) {
        guard let s = session else { return }
        
        let completedSession = urgeService.completeSession(s, intensityAfter: intensityAfter)
        self.session = completedSession
        
        // Phase 3: Stop Shielding
        FocusService.shared.stopShielding()
        
        // Check for specific rewards (mock)
        reward = RewardService.checkForNewRewards(user: urgeService.currentUser, sessions: urgeService.recentSessions)
        
        withAnimation {
            currentState = .summary
        }
        Haptics.playSuccess()
    }
    
    func dismiss() {
        FocusService.shared.stopShielding()
    }
}
