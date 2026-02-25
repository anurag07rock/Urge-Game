import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    let urgeService: UrgeService
    @EnvironmentObject var themeManager: ThemeManager
    
    init(urgeService: UrgeService) {
        self.urgeService = urgeService
        _viewModel = StateObject(wrappedValue: HomeViewModel(urgeService: urgeService))
    }
    
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.ubBackground.ignoresSafeArea()
                
                // Background Aesthetic Elements
                backgroundGlows
                
                // Main Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 36) {
                        // Header & Stats Grouped
                        VStack(spacing: 24) {
                            headerView
                            statsView
                        }
                        .padding(.top, 20)
                        
                        // Main Action Section
                        VStack(spacing: 12) {
                            urgeButtonView
                        }
                        .padding(.vertical, 10)
                        
                        // Insights Section
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(title: "Weekly Activity", icon: "chart.xyaxis.line")
                            WeeklyGraphView(data: viewModel.weeklyData)
                            
                            NavigationLink(destination: DashboardView(urgeService: urgeService)) {
                                DashboardCardView()
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .padding(.horizontal, Theme.layoutPadding)
                }
                
                // Game Session Overlay (ZStack presentation for smooth animation)
                if viewModel.showingGameSession {
                    GameSessionView(isPresented: $viewModel.showingGameSession, urgeService: urgeService, namespace: animation)
                        .transition(.asymmetric(
                            insertion: .modifier(
                                active: OpacityBlurModifier(opacity: 0, blur: 20),
                                identity: OpacityBlurModifier(opacity: 1, blur: 0)
                            ),
                            removal: .opacity
                        ))
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Late Night Mode"
        }
    }
    
    private var backgroundGlows: some View {
        ZStack {
            Circle()
                .fill(Color.ubPrimary.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: -150, y: -200)
            
            Circle()
                .fill(Color.ubSecondary.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 100, y: 150)
        }
        .ignoresSafeArea()
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greeting)
                    .font(Theme.fontSubheadline)
                    .foregroundColor(.secondary)
                Text("Breathe & Focus")
                    .font(Theme.fontLargeTitle)
                    .foregroundColor(.ubPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Focus Settings
                NavigationLink(destination: FocusSettingsView()) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.ubPrimary)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.ubSurface)
                                .shadow(color: Theme.Shadows.card, radius: 4, x: 0, y: 2)
                        )
                }
                
                // Theme Toggle
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
            }
        }
    }
    
    private var statsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatsCardView(
                    title: "Level \(viewModel.level)",
                    value: viewModel.totalPoints,
                    icon: "arrow.up.circle.fill",
                    color: .ubAccent
                )
                
                StatsCardView(
                    title: "Streak",
                    value: viewModel.currentStreak,
                    icon: "flame.fill",
                    color: .ubPrimary
                )
            }
            
            // Level Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to Level \(viewModel.level + 1)")
                        .font(Theme.fontCaption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(viewModel.levelProgress * 100))%")
                        .font(Theme.fontCaption)
                        .fontWeight(.bold)
                        .foregroundColor(.ubPrimary)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.ubPrimary.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.ubPrimary, .ubSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * CGFloat(viewModel.levelProgress))
                            .overlay(
                                ShimmerOverlay()
                                    .mask(
                                        RoundedRectangle(cornerRadius: 6)
                                    )
                            )
                    }
                }
                .frame(height: 12)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: Theme.layoutRadius)
                    .fill(Color.ubCardBackground)
                    .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 5)
            )
        }
    }
    
    private var urgeButtonView: some View {
        VStack {
            if !viewModel.showingGameSession {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.startUrgeSession()
                    }
                }) {
                    urgeButtonContent
                }
                .buttonStyle(UrgeButtonStyle(size: 220, animation: animation))
            } else {
                Color.clear.frame(height: 220)
            }
        }
    }
    
    private var urgeButtonContent: some View {
        VStack(spacing: 8) {
            if #available(iOS 17.0, *) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 56))
                    .symbolEffect(.pulse.byLayer, options: .repeating)
                    .matchedGeometryEffect(id: "urgeButtonIcon", in: animation)
            } else {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 56))
                    .matchedGeometryEffect(id: "urgeButtonIcon", in: animation)
            }
            Text("I Feel an Urge")
                .font(Theme.fontHeadline)
                .fontWeight(.bold)
                .matchedGeometryEffect(id: "urgeButtonText", in: animation)
        }
        .frame(width: 220, height: 220)
        .contentShape(Circle())
    }
}

// MARK: - Components

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.ubPrimary)
                .font(.system(size: 16, weight: .semibold))
            
            Text(title)
                .font(Theme.fontHeadline)
                .foregroundColor(.ubTextPrimary)
            
            Spacer()
        }
    }
}

// Helper transition modifier
struct OpacityBlurModifier: ViewModifier {
    let opacity: Double
    let blur: CGFloat
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .blur(radius: blur)
    }
}

struct UrgeButtonStyle: ButtonStyle {
    var size: CGFloat = 250
    var animation: Namespace.ID
    @State private var isBreathing = false
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.4
    @State private var heartbeatScale: CGFloat = 1.0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Periodic ripple ring (every 4s)
            Circle()
                .stroke(Color.ubPrimary.opacity(rippleOpacity), lineWidth: 2)
                .frame(width: size, height: size)
                .scaleEffect(rippleScale)
            
            // Ripple / Glow Effect (Outer)
            Circle()
                .fill(Color.ubPrimary.opacity(0.12))
                .frame(width: size * 1.25, height: size * 1.25)
                .scaleEffect(isBreathing && !configuration.isPressed ? 1.04 : 1.0)
                .opacity(isBreathing && !configuration.isPressed ? 1.0 : 0.6)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 3).repeatForever(autoreverses: true),
                    value: isBreathing
                )
            
            // Inner Ripple
            Circle()
                .fill(Color.ubPrimary.opacity(0.18))
                .frame(width: size * 1.1, height: size * 1.1)
                .scaleEffect(isBreathing && !configuration.isPressed ? 1.08 : 1.0)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
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
                .matchedGeometryEffect(id: "urgeButton", in: animation)
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
                .scaleEffect(configuration.isPressed ? 0.96 : heartbeatScale)
            
            // Content
            configuration.label
                .foregroundColor(.white)
                .scaleEffect(configuration.isPressed ? 0.96 : heartbeatScale)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: configuration.isPressed)
        .onAppear {
            isBreathing = true
            if !reduceMotion {
                startHeartbeat()
                startRipple()
            }
        }
        .onChange(of: configuration.isPressed) { pressed in
            if pressed {
                Haptics.playSelection()
            }
        }
    }
    
    private func startHeartbeat() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                    heartbeatScale = 1.06
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                        heartbeatScale = 1.0
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                        heartbeatScale = 1.04
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        heartbeatScale = 1.0
                    }
                }
            }
        }
    }
    
    private func startRipple() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            DispatchQueue.main.async {
                rippleScale = 1.0
                rippleOpacity = 0.4
                withAnimation(.easeOut(duration: 1.5)) {
                    rippleScale = 1.6
                    rippleOpacity = 0
                }
            }
        }
    }
}
