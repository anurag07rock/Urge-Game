import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var totalSessions: Int = 0
    @Published var sessionsToday: Int = 0
    @Published var totalPoints: Int = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var history: [UrgeSession] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let urgeService: UrgeService
    
    init(urgeService: UrgeService = UrgeService()) {
        self.urgeService = urgeService
        
        // Subscribe to changes in UrgeService
        urgeService.$currentUser
            .combineLatest(urgeService.$recentSessions)
            .receive(on: RunLoop.main)
            .sink { [weak self] user, sessions in
                self?.updateStats(user: user, sessions: sessions)
            }
            .store(in: &cancellables)
    }
    
    private func updateStats(user: User, sessions: [UrgeSession]) {
        self.totalPoints = user.totalPoints
        self.currentStreak = user.currentStreak
        self.longestStreak = user.longestStreak
        self.history = sessions
        self.totalSessions = sessions.count // simplified, usually filtered by completion
        
        let today = Date()
        self.sessionsToday = sessions.filter { session in
            guard let end = session.endedAt else { return false }
            return Calendar.current.isDate(end, inSameDayAs: today)
        }.count
    }
}
