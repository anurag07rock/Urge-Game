import Foundation

class RewardService {
    // Defines rules for unlocking rewards (mock implementation for simplicity)
    // In a full app, this would check criteria against the user stats
    
    static func checkForNewRewards(user: User, sessions: [UrgeSession]) -> Reward? {
        // Example logic
        if user.currentStreak == 3 {
             return Reward(id: UUID(), title: "3 Day Streak!", description: "You're on a roll.", unlockedAt: Date())
        }
        if user.totalPoints >= 100 && user.totalPoints <= 110 {
            return Reward(id: UUID(), title: "Century Club", description: "Earned 100 points.", unlockedAt: Date())
        }
        return nil
    }
}
