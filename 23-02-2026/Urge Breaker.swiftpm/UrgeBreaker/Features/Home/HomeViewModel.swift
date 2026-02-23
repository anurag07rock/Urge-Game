import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var totalPoints: Int = 0
    @Published var currentStreak: Int = 0
    @Published var showingGameSession: Bool = false
    
    @Published var level: Int = 1
    @Published var levelProgress: Double = 0.0
    @Published var weeklyData: [(day: String, count: Int, isToday: Bool)] = []
    
    // ... existing properties
    
    private var cancellables = Set<AnyCancellable>()
    private let urgeService: UrgeService
    
    init(urgeService: UrgeService) {
        self.urgeService = urgeService
        
        urgeService.$currentUser
            .receive(on: RunLoop.main)
            .sink { [weak self] user in
                self?.totalPoints = user.totalPoints
                self?.currentStreak = user.currentStreak
                self?.level = user.level
                self?.levelProgress = user.progressToNextLevel
            }
            .store(in: &cancellables)
            
        urgeService.$recentSessions
            .receive(on: RunLoop.main)
            .sink { [weak self] sessions in
                self?.calculateWeeklyData(sessions)
            }
            .store(in: &cancellables)
    }
    
    func startUrgeSession() {
        showingGameSession = true
    }
    
    private func calculateWeeklyData(_ sessions: [UrgeSession]) {
        let calendar = Calendar.current
        let today = Date()
        var data: [(day: String, count: Int, isToday: Bool)] = []
        
        // Loop back 7 days (including today)
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let count = sessions.filter {
                $0.completed && $0.startedAt >= dayStart && $0.startedAt < dayEnd
            }.count
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE" // Mon, Tue
            let dayLabel = formatter.string(from: date)
            let isToday = calendar.isDateInToday(date)
            
            data.append((day: dayLabel, count: count, isToday: isToday))
        }
        
        self.weeklyData = data
    }
}
