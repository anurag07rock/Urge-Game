import Foundation
import Combine

class UrgeService: ObservableObject {
    @Published var currentUser: User
    @Published var recentSessions: [UrgeSession]
    
    private let persistence = PersistenceService.shared
    
    init() {
        self.currentUser = persistence.load(User.self, forKey: Constants.Keys.user) ?? User()
        self.recentSessions = persistence.load([UrgeSession].self, forKey: Constants.Keys.sessions) ?? []
    }
    
    func createSession(gameType: GameType, intensity: Int?) -> UrgeSession {
        let session = UrgeSession(gameType: gameType, intensityBefore: intensity)
        return session
    }
    
    func completeSession(_ session: UrgeSession, intensityAfter: Int?) -> UrgeSession {
        var completedSession = session
        completedSession.endedAt = Date()
        completedSession.completed = true
        completedSession.urgeIntensityAfter = intensityAfter
        completedSession.pointsEarned = 10 // Base points
        
        if let before = session.urgeIntensityBefore, let after = intensityAfter, after < before {
            completedSession.urgePassed = true
        } else {
             // Even if intensity didn't drop, completing the distraction is a win
             completedSession.urgePassed = true
        }
        
        // Update User
        currentUser.totalPoints += completedSession.pointsEarned
        currentUser = StreakService.shared.calculateStreak(currentUser: currentUser, completionDate: Date())
        
        // Save Session
        recentSessions.insert(completedSession, at: 0)
        
        saveData()
        
        return completedSession
    }
    
    private func saveData() {
        persistence.save(currentUser, forKey: Constants.Keys.user)
        persistence.save(recentSessions, forKey: Constants.Keys.sessions)
    }
}
