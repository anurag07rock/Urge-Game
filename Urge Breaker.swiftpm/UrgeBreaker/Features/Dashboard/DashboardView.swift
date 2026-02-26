import SwiftUI

struct DashboardView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: DashboardViewModel
    
    init(urgeService: UrgeService) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(urgeService: urgeService))
    }
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundColor(.ubPrimary)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    
                    Text("Dashboard")
                        .font(Theme.fontLargeTitle)
                        .foregroundColor(.ubTextPrimary)
                }
                .padding(.horizontal, Theme.layoutPadding)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.ubBackground)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Summary Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(title: "Today", value: "\(viewModel.sessionsToday)")
                            StatCard(title: "Total Urges", value: "\(viewModel.totalSessions)")
                            StatCard(title: "Current Streak", value: "\(viewModel.currentStreak)")
                            StatCard(title: "Best Streak", value: "\(viewModel.longestStreak)")
                        }
                        .scrollReveal(index: 0)
                        
                        // Points Banner
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Points")
                                    .font(Theme.fontSubheadline)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.totalPoints)")
                                    .font(Theme.fontTitle)
                                    .foregroundColor(.ubAccent)
                            }
                            Spacer()
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.yellow)
                                .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(20)
                        .background(Color.ubCardBackground)
                        .cornerRadius(Theme.layoutRadius)
                        .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 4)
                        .scrollReveal(index: 1)
                        
                        // Weekly Insights
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Weekly Insights")
                                .font(Theme.fontHeadline)
                                .foregroundColor(.ubTextPrimary)
                            
                            if viewModel.triggerDistribution.isEmpty {
                                Text("Complete more sessions to see your trigger patterns.")
                                    .font(Theme.fontBody)
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                VStack(spacing: 20) {
                                    // Trigger Chart
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(Trigger.allCases) { trigger in
                                            let count = viewModel.triggerDistribution[trigger] ?? 0
                                            let maxCount = viewModel.triggerDistribution.values.max() ?? 1
                                            let ratio = Double(count) / Double(maxCount)
                                            
                                            HStack(spacing: 12) {
                                                Image(systemName: trigger.icon)
                                                    .foregroundColor(.ubPrimary)
                                                    .frame(width: 24)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack {
                                                        Text(trigger.displayName)
                                                            .font(Theme.fontCaption)
                                                            .foregroundColor(.ubTextPrimary)
                                                        Spacer()
                                                        Text("\(count)")
                                                            .font(Theme.fontCaption)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.secondary)
                                                    }
                                                    
                                                    GeometryReader { geo in
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .fill(Color.ubPrimary.opacity(0.1))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 4)
                                                                    .fill(Color.ubPrimary)
                                                                    .frame(width: geo.size.width * CGFloat(ratio)),
                                                                alignment: .leading
                                                            )
                                                    }
                                                    .frame(height: 8)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Personalized Suggestion
                                    if let top = viewModel.topTrigger {
                                        HStack(spacing: 16) {
                                            Image(systemName: "lightbulb.fill")
                                                .font(.title2)
                                                .foregroundColor(.yellow)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Observation")
                                                    .font(Theme.fontCaption)
                                                    .foregroundColor(.secondary)
                                                    .textCase(.uppercase)
                                                Text(triggerSuggestion(for: top))
                                                    .font(Theme.fontSubheadline)
                                                    .foregroundColor(.ubTextPrimary)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                        .padding()
                                        .background(Color.ubPrimary.opacity(0.05))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.ubCardBackground)
                        .cornerRadius(Theme.layoutRadius)
                        .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 4)
                        .scrollReveal(index: 2)
                        // History Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent History")
                                .font(Theme.fontHeadline)
                                .foregroundColor(.ubTextPrimary)
                                .padding(.leading, 4)
                            
                            if viewModel.history.isEmpty {
                                Text("No sessions yet. Your journey starts today!")
                                    .font(Theme.fontBody)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(Array(viewModel.history.enumerated()), id: \.element.id) { index, session in
                                        HistoryRow(session: session)
                                            .scrollReveal(index: index)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Theme.layoutPadding)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func triggerSuggestion(for trigger: Trigger) -> String {
        let game: String
        switch trigger {
        case .stress:
            game = "Logic Code Breaker"
        case .boredom:
            game = "Minimal 2048"
        case .loneliness:
            game = "Zen Sudoku"
        case .habit:
            game = "Sliding Puzzle"
        }
        return "\(trigger.displayName) is your primary trigger. Try '\(game)' to help manage it."
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(Theme.fontTitle)
                .foregroundColor(.ubPrimary)
            Text(title)
                .font(Theme.fontCaption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.ubCardBackground)
        .cornerRadius(Theme.layoutRadius)
        .shadow(color: Theme.Shadows.card, radius: 8, x: 0, y: 2)
    }
}

struct HistoryRow: View {
    let session: UrgeSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.gameType.displayName)
                    .font(Theme.fontHeadline)
                    .foregroundColor(.ubTextPrimary)
                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(Theme.fontCaption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if session.pointsEarned > 0 {
                HStack(spacing: 4) {
                    Text("+\(session.pointsEarned)")
                        .font(Theme.fontHeadline)
                        .foregroundColor(.ubSuccess)
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.ubSuccess)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.ubSuccess.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.ubCardBackground)
        .cornerRadius(16)
        .shadow(color: Theme.Shadows.card, radius: 5, x: 0, y: 1)
    }
}
