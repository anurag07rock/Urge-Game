import Foundation

final class StreakService: @unchecked Sendable {
    static let shared = StreakService()
    
    // Pure function for testability
    func calculateStreak(currentUser: User, completionDate: Date) -> User {
        var updatedUser = currentUser
        let today = completionDate
        
        // If it's the first completion ever
        guard let lastDate = updatedUser.lastCompletedDate else {
            updatedUser.currentStreak = 1
            updatedUser.longestStreak = 1
            updatedUser.lastCompletedDate = today
            return updatedUser
        }
        
        // Check if same day
        if today.isSameDay(as: lastDate) {
            // Already completed something today, streak doesn't increase but doesn't break
            updatedUser.lastCompletedDate = today 
            return updatedUser
        }
        
        // Check if consecutive day using reliable Calendar arithmetic
        let calendar = Calendar.current
        let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: today)).day ?? 0
        if daysBetween == 1 {
            // Yesterday — streak continues
            updatedUser.currentStreak += 1
        } else if daysBetween > 1 {
            // Missed one or more days — reset
            updatedUser.currentStreak = 1
        }
        // daysBetween == 0 already handled above (same day case)
        
        // Update longest
        if updatedUser.currentStreak > updatedUser.longestStreak {
            updatedUser.longestStreak = updatedUser.currentStreak
        }
        
        updatedUser.lastCompletedDate = today
        return updatedUser
    }
    
    // Legacy support or direct access if needed
    func updateStreak(for user: inout User) {
        user = calculateStreak(currentUser: user, completionDate: Date())
    }
}
