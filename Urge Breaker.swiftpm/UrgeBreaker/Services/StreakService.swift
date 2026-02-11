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
        
        // Check if yesterday (consecutive day)
        if today.isYesterday(relativeTo: lastDate.addingTimeInterval(86400)) { // lastDate + 1 day should be around today
             // More robust: is 'lastDate' yesterday relative to 'today'?
             if Calendar.current.isDate(lastDate, inSameDayAs: today.addingTimeInterval(-86400)) {
                 updatedUser.currentStreak += 1
             } else {
                 // It's been more than a day
                 updatedUser.currentStreak = 1
             }
        } else {
             // Reset
             updatedUser.currentStreak = 1
        }
        
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
