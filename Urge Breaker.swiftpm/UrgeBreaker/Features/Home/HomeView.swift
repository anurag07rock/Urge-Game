import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    let urgeService: UrgeService
    @EnvironmentObject var themeManager: ThemeManager
    
    init(urgeService: UrgeService) {
        self.urgeService = urgeService
        _viewModel = StateObject(wrappedValue: HomeViewModel(urgeService: urgeService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.ubBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello, There")
                                .font(Theme.fontLargeTitle)
                                .foregroundColor(.ubPrimary)
                            Text("Ready to beat an urge?")
                                .font(Theme.fontSubheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Theme Toggle Button
                        Button(action: {
                            Haptics.playSelection()
                            themeManager.toggleTheme()
                        }) {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(themeManager.isDarkMode ? .yellow : .orange)
                                .padding(10)
                                .background(
                                    Circle()
                                        .fill(Color.ubSurface)
                                        .shadow(color: Theme.Shadows.card, radius: 4, x: 0, y: 2)
                                )
                        }
                        .accessibilityLabel(themeManager.isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode")
                    }
                    .padding(.horizontal, Theme.layoutPadding)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // Header Stats
                    HStack(spacing: 16) {
                        StatsCardView(
                            title: "Total Points",
                            value: viewModel.totalPoints,
                            icon: "star.fill",
                            color: .ubAccent
                        )
                        
                        StatsCardView(
                            title: "Current Streak",
                            value: viewModel.currentStreak,
                            icon: "flame.fill",
                            color: .ubPrimary
                        )
                    }
                    .padding(.horizontal, Theme.layoutPadding)
                    
                    Spacer(minLength: 20)
                    
                    // Main Action Button (Floating / Prominent) - Scaled Down slightly for fit
                    Button(action: {
                        Haptics.playSuccess() // Light feedback on trigger
                        viewModel.startUrgeSession()
                    }) {
                        VStack(spacing: 6) {
                            if #available(iOS 17.0, *) {
                                Image(systemName: "waveform.path.ecg")
                                    .font(.system(size: 48))
                                    .symbolEffect(.pulse.byLayer, options: .repeating, isActive: true)
                            } else {
                                Image(systemName: "waveform.path.ecg")
                                    .font(.system(size: 48))
                            }
                            Text("I Feel an Urge")
                                .font(Theme.fontHeadline)
                                .fontWeight(.bold)
                        }
                        .frame(width: 200, height: 200) // Compact size
                        .contentShape(Circle())
                    }
                    .buttonStyle(UrgeButtonStyle(size: 200)) // Pass size to style
                    
                    Spacer(minLength: 20)
                    
                    // Weekly Graph
                    WeeklyGraphView(data: viewModel.weeklyData)
                        .padding(.horizontal, Theme.layoutPadding)
                    
                    Spacer(minLength: 20)
                    
                    // Dashboard Link
                    NavigationLink(destination: DashboardView()) {
                        DashboardCardView()
                    }
                    .padding(.horizontal, Theme.layoutPadding)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $viewModel.showingGameSession) {
                GameSessionView(isPresented: $viewModel.showingGameSession, urgeService: urgeService)
            }
        }
    }
}

struct UrgeButtonStyle: ButtonStyle {
    var size: CGFloat = 250 // Default size
    @State private var isBreathing = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Ripple / Glow Effect (Outer)
            Circle()
                .fill(Color.ubPrimary.opacity(0.15))
                .frame(width: size + 40, height: size + 40)
                .scaleEffect(isBreathing && !configuration.isPressed ? 1.05 : 1.0)
                .opacity(isBreathing && !configuration.isPressed ? 1.0 : 0.6)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true),
                    value: isBreathing
                )
            
            // Main Circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.ubPrimary, Color.ubPrimary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .shadow(
                    color: Color.ubPrimary.opacity(0.4),
                    radius: configuration.isPressed ? 10 : 20,
                    x: 0,
                    y: configuration.isPressed ? 5 : 10
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            
            // Content
            configuration.label
                .foregroundColor(.white)
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: configuration.isPressed)
        .onAppear {
            isBreathing = true
        }
        .onChange(of: configuration.isPressed) { pressed in
            if pressed {
                Haptics.playSelection() // Light feedback on press down
            }
        }
    }
}
