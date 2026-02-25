import SwiftUI
import Combine

@MainActor
class GameSessionViewModel: ObservableObject {
    enum State {
        case preCheck
        case gamePicker
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
    @Published var gameOptions: [GameType] = []
    
    @Published var appreciationMessage: String = ""
    
    private let urgeService: UrgeService
    
    init(urgeService: UrgeService) {
        self.urgeService = urgeService
    }
    
    func startSession() {
        // Build game options based on trigger
        if let trigger = selectedTrigger {
            switch trigger {
            case .stress:
                gameOptions = [.volcanoVent, .waveRider, .thunderJar]
            case .boredom:
                gameOptions = [.bubblePopBlitz, .iceSculptor, .moodMixer]
            case .loneliness:
                gameOptions = [.connectionConstellation, .rootAndGrow, .mirrorMind]
            case .habit:
                gameOptions = [.patternBreak, .unravel, .summitClimb]
            }
        } else {
            // Default intensity-based selection (no picker needed)
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
            
            guard let game = selectedGame else { return }
            var newSession = urgeService.createSession(gameType: game, intensity: Int(intensity))
            newSession.trigger = selectedTrigger
            self.session = newSession
            
            if urgeService.currentUser.focusShieldEnabled {
                FocusService.shared.startShielding()
            }
            
            withAnimation {
                currentState = .instructions
            }
            return
        }
        
        // Show game picker when trigger is selected
        withAnimation {
            currentState = .gamePicker
        }
    }
    
    func selectGame(_ game: GameType) {
        selectedGame = game
        
        var newSession = urgeService.createSession(gameType: game, intensity: Int(intensity))
        newSession.trigger = selectedTrigger
        self.session = newSession
        
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
        
        FocusService.shared.stopShielding()
        
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
