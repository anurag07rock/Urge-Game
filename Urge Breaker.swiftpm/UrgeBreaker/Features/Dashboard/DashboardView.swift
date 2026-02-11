import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    @Environment(\.presentationMode) var presentationMode
    
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
                                    ForEach(viewModel.history) { session in
                                        HistoryRow(session: session)
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
