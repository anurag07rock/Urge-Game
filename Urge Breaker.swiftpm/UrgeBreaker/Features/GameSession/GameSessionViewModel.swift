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
    @Published var selectedGame: GameType?
    @Published var session: UrgeSession?
    @Published var reward: Reward?
    
    @Published var appreciationMessage: String = ""
    
    private let urgeService: UrgeService
    
    init(urgeService: UrgeService) {
        self.urgeService = urgeService
    }
    
    func startSession() {
        // Select game based on intensity
        switch Int(intensity) {
        case 1:
            selectedGame = .tapChallenge
        case 2:
            selectedGame = .memoryPuzzle
        case 3:
            selectedGame = .focusHold
        case 4:
            selectedGame = .breathing
        case 5:
            selectedGame = .grounding
        default:
            selectedGame = GameType.allCases.randomElement()!
        }
        
        session = urgeService.createSession(gameType: selectedGame!, intensity: Int(intensity))
        
        session = urgeService.createSession(gameType: selectedGame!, intensity: Int(intensity))
        
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
        
        // Check for specific rewards (mock)
        reward = RewardService.checkForNewRewards(user: urgeService.currentUser, sessions: urgeService.recentSessions)
        
        withAnimation {
            currentState = .summary
        }
        Haptics.playSuccess()
    }
}
