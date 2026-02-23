import SwiftUI

struct GameSessionView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var urgeService: UrgeService
    @StateObject var viewModel: GameSessionViewModel
    
    var namespace: Namespace.ID? = nil
    
    init(isPresented: Binding<Bool>, urgeService: UrgeService, namespace: Namespace.ID? = nil) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: GameSessionViewModel(urgeService: urgeService))
        self.namespace = namespace
    }
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            switch viewModel.currentState {
            case .preCheck:
                PreGameCheckInView(
                    intensity: $viewModel.intensity,
                    selectedTrigger: $viewModel.selectedTrigger,
                    onContinue: { viewModel.startSession() },
                    namespace: namespace
                )
                .transition(.opacity)

            case .instructions:
                if let gameType = viewModel.selectedGame {
                    GameInstructionView(gameType: gameType) {
                        viewModel.startGameConfirmed()
                    }
                    .transition(.opacity)
                }
                
            case .playing:
                if let gameType = viewModel.selectedGame {
                    GameFactory.createView(for: gameType, intensity: Int(viewModel.intensity)) {
                        viewModel.gameCompleted()
                    }
                    .transition(.opacity)
                }
                
            case .postCheck:
                PostGameCheckInView(
                    appreciationMessage: viewModel.appreciationMessage,
                    beforeIntensity: Int(viewModel.intensity)
                ) { selectedIntensity in
                    viewModel.completeSession(intensityAfter: selectedIntensity)
                }
                .transition(.opacity)

            case .summary:
                SessionSummaryView(
                    points: viewModel.session?.pointsEarned ?? 0,
                    reward: viewModel.reward,
                    intensityBefore: viewModel.session?.urgeIntensityBefore ?? Int(viewModel.intensity),
                    intensityAfter: viewModel.session?.urgeIntensityAfter ?? 1,
                    onHome: {
                        viewModel.dismiss()
                        isPresented = false
                    },
                    onPlayAgain: {
                        viewModel.playAgain()
                    }
                )
                .transition(.opacity)
            }
        }
        .overlay(
            GameBackButton(onDismiss: {
                viewModel.dismiss()
                isPresented = false
            })
            .padding(.leading, 20)
            .padding(.top, 20),
            alignment: .topLeading
        )

        .onAppear {
            // Re-inject the correct instance if needed, or pass via init in HomeView
        }
    }
}

// Subviews (Internal for simplicity)

struct PreGameCheckInView: View {
    @Binding var intensity: Double
    @Binding var selectedTrigger: Trigger?
    var onContinue: () -> Void
    var namespace: Namespace.ID?
    
    var body: some View {
        ZStack {
            // Background Wave
            UrgeWaveView(intensity: intensity)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.6)
            
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Text("Check In")
                        .font(Theme.fontSubheadline)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                        
                    Text("How strong is the urge?")
                        .font(Theme.fontTitle)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.ubTextPrimary)
                }
                .padding(.top, 60)
                
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.ubSurface)
                                .frame(width: 180, height: 180)
                                .shadow(color: Theme.Shadows.card, radius: 15, x: 0, y: 10)
                            
                            VStack {
                                if #available(iOS 17.0, *) {
                                    Text("\(Int(intensity))")
                                        .font(.system(size: 80, weight: .bold, design: .rounded))
                                        .foregroundColor(.ubPrimary)
                                        .contentTransition(.numericText())
                                        .animation(.snappy, value: intensity)
                                        .modifier(MatchedGeometryModifier(id: "urgeButtonText", namespace: namespace))
                                } else {
                                    if let namespace = namespace {
                                        Text("\(Int(intensity))")
                                            .font(.system(size: 80, weight: .bold, design: .rounded))
                                            .foregroundColor(.ubPrimary)
                                            .matchedGeometryEffect(id: "urgeButtonText", in: namespace)
                                    } else {
                                        Text("\(Int(intensity))")
                                            .font(.system(size: 80, weight: .bold, design: .rounded))
                                            .foregroundColor(.ubPrimary)
                                    }
                                }
                            }
                        }
                        .matchedGeometryEffect(id: "urgeButton", in: namespace ?? Namespace().wrappedValue)
                    
                    Text(intensityDescription(for: Int(intensity)))
                        .font(Theme.fontHeadline)
                        .foregroundColor(.secondary)
                        .animation(.snappy, value: intensity)
                }
                
                VStack(spacing: 10) {
                    Slider(value: $intensity, in: 1...5, step: 1)
                        .tint(.ubPrimary)
                    
                    HStack {
                        Text("Mild")
                        Spacer()
                        Text("Intense")
                    }
                    .font(Theme.fontCaption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
                
                // Trigger Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("What triggered this?")
                        .font(Theme.fontHeadline)
                        .padding(.horizontal, 40)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Trigger.allCases) { trigger in
                                TriggerChip(
                                    trigger: trigger,
                                    isSelected: selectedTrigger == trigger,
                                    action: {
                                        if selectedTrigger == trigger {
                                            selectedTrigger = nil
                                        } else {
                                            selectedTrigger = trigger
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    Haptics.playSuccess()
                    onContinue()
                }) {
                    Text("Start Intervention")
                        .font(Theme.fontHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Theme.layoutRadius)
                                .fill(Color.ubPrimary)
                                .shadow(color: Color.ubPrimary.opacity(0.4), radius: 10, x: 0, y: 5)
                        )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    func intensityDescription(for level: Int) -> String {
        switch level {
        case 1: return "Very Mild"
        case 2: return "Manageable"
        case 3: return "Moderate"
        case 4: return "Strong"
        case 5: return "Overwhelming"
        default: return ""
        }
    }
}

struct PostGameCheckInView: View {
    let appreciationMessage: String
    let beforeIntensity: Int
    var onComplete: (Int) -> Void // Passes back intensity
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 8) {
                Text(appreciationMessage)
                    .font(Theme.fontHeadline)
                    .foregroundColor(.ubPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(Color.ubSubtleBackground)
                    .cornerRadius(16)
                
                HStack {
                    Text("Starting Intensity:")
                    Text("\(beforeIntensity)")
                        .fontWeight(.bold)
                        .foregroundColor(.ubPrimary)
                }
                .font(Theme.fontSubheadline)
            }
            .padding(.horizontal, 24)
            
            Text("How do you feel now?")
                .font(Theme.fontTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.ubTextPrimary)
            
            VStack(spacing: 16) {
                ReflectionButton(title: "Much Better", color: .ubSuccess, icon: "heart.fill") {
                    onComplete(max(1, beforeIntensity - 2))
                }
                
                ReflectionButton(title: "Slightly Better", color: .ubSecondary, icon: "hand.thumbsup.fill") {
                    onComplete(max(1, beforeIntensity - 1))
                }
                
                ReflectionButton(title: "About the same", color: .ubAccent, icon: "equal.circle.fill") {
                    onComplete(beforeIntensity)
                }
                
                ReflectionButton(title: "Still intense", color: .ubDanger, icon: "exclamationmark.triangle.fill") {
                    onComplete(5)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}

struct ReflectionButton: View {
    let title: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(Theme.fontHeadline)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.white)
            .padding()
            .frame(height: 60)
            .background(color)
            .cornerRadius(Theme.layoutRadius)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct SessionSummaryView: View {
    let points: Int
    let reward: Reward?
    let intensityBefore: Int
    let intensityAfter: Int
    var onHome: () -> Void
    var onPlayAgain: () -> Void
    
    @State private var animateContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer().frame(height: 40)
                
                if #available(iOS 17.0, *) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.ubSuccess)
                        .symbolEffect(.bounce, value: animateContent)
                        .shadow(color: .ubSuccess.opacity(0.4), radius: 20, x: 0, y: 10)
                } else {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.ubSuccess)
                        .shadow(color: .ubSuccess.opacity(0.4), radius: 20, x: 0, y: 10)
                }
                
                VStack(spacing: 8) {
                    Text("Growth Achievement")
                        .font(Theme.fontSubheadline)
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    
                    Text("Urge Managed")
                        .font(Theme.fontTitle)
                        .foregroundColor(.ubTextPrimary)
                }
                
                // Intensity Comparison Card
                HStack(spacing: 0) {
                    VStack {
                        Text("\(intensityBefore)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.ubDanger)
                        Text("Before")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Image(systemName: "arrow.right")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    VStack {
                        Text("\(intensityAfter)")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.ubSuccess)
                        Text("After")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.ubSurface)
                .cornerRadius(Theme.layoutRadius)
                .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.ubAccent)
                        Text("Points Earned: \(points)")
                            .font(Theme.fontHeadline)
                        Spacer()
                    }
                    .padding()
                    .background(Color.ubSubtleBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                if let reward = reward {
                    VStack(spacing: 8) {
                        Text("New Reward Unlocked!")
                            .font(Theme.fontHeadline)
                            .foregroundColor(.ubAccent)
                            .textCase(.uppercase)
                        
                        Text(reward.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.ubTextPrimary)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.ubCardBackground)
                    .cornerRadius(Theme.layoutRadius)
                    .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                    .scaleEffect(animateContent ? 1 : 0.9)
                    .opacity(animateContent ? 1 : 0)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: onHome) {
                        Text("Back to Home")
                            .font(Theme.fontHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.ubPrimary)
                            .cornerRadius(Theme.layoutRadius)
                    }
                    .shadow(color: Color.ubPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Button("Keep Going", action: onPlayAgain)
                        .font(Theme.fontHeadline)
                        .foregroundColor(.ubPrimary)
                        .padding()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6, bounce: 0.4)) {
                animateContent = true
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.fontHeadline)
            .foregroundColor(.white)
            .frame(width: 200, height: 50)
            .background(Color.ubPrimary)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// Helper for optional MatchedGeometry
struct MatchedGeometryModifier: ViewModifier {
    let id: String
    let namespace: Namespace.ID?
    
    func body(content: Content) -> some View {
        if let namespace = namespace {
            content.matchedGeometryEffect(id: id, in: namespace)
        } else {
            content
        }
    }
}
