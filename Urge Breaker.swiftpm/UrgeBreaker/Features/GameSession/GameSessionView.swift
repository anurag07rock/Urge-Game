import SwiftUI

struct GameSessionView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var urgeService: UrgeService
    @StateObject var viewModel: GameSessionViewModel
    
    init(isPresented: Binding<Bool>, urgeService: UrgeService) {
        _isPresented = isPresented
        _viewModel = StateObject(wrappedValue: GameSessionViewModel(urgeService: urgeService))
    }
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            switch viewModel.currentState {
            case .preCheck:
                PreGameCheckInView(intensity: $viewModel.intensity) {
                    viewModel.startSession()
                }
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
                PostGameCheckInView(appreciationMessage: viewModel.appreciationMessage) { selectedIntensity in
                    viewModel.completeSession(intensityAfter: selectedIntensity)
                }
                .transition(.opacity)

            case .summary:
                SessionSummaryView(
                    points: viewModel.session?.pointsEarned ?? 0,
                    reward: viewModel.reward,
                    onHome: {
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
            Group {
                if viewModel.currentState != .playing {
                    GameBackButton(onDismiss: {
                        isPresented = false
                    })
                    .padding(.leading, 20)
                    .padding(.top, 20)
                }
            },
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
    var onContinue: () -> Void
    
    var body: some View {
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
                if #available(iOS 17.0, *) {
                    Text("\(Int(intensity))")
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .foregroundColor(.ubPrimary)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: intensity)
                } else {
                    Text("\(Int(intensity))")
                        .font(.system(size: 96, weight: .bold, design: .rounded))
                        .foregroundColor(.ubPrimary)
                }
                
                Text(intensityDescription(for: Int(intensity)))
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
                    .animation(.snappy, value: intensity)
            }
            
            Slider(value: $intensity, in: 1...5, step: 1)
                .tint(.ubPrimary)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Start Session")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.ubPrimary)
                    .cornerRadius(Theme.layoutRadius)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
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
    var onComplete: (Int) -> Void // Passes back intensity
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text(appreciationMessage)
                .font(Theme.fontHeadline)
                .foregroundColor(.ubPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.vertical, 20)
                .background(Color.ubSubtleBackground)
                .cornerRadius(16)
                .padding(.horizontal, 24)
            
            Text("How do you feel now?")
                .font(Theme.fontTitle)
                .multilineTextAlignment(.center)
                .foregroundColor(.ubTextPrimary)
            
            VStack(spacing: 16) {
                ReflectionButton(title: "Better", color: .ubSuccess) {
                    onComplete(1)
                }
                
                ReflectionButton(title: "About the same", color: .ubSecondary) {
                    onComplete(3)
                }
                
                ReflectionButton(title: "Still intense", color: .ubDanger) {
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
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
    var onHome: () -> Void
    var onPlayAgain: () -> Void
    
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if #available(iOS 17.0, *) {
                Image(systemName: "star.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.yellow)
                    .symbolEffect(.bounce, value: animateContent)
                    .shadow(color: .orange.opacity(0.4), radius: 20, x: 0, y: 10)
            } else {
                Image(systemName: "star.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange.opacity(0.4), radius: 20, x: 0, y: 10)
            }
            
            VStack(spacing: 8) {
                Text("Well Done!")
                    .font(Theme.fontTitle)
                    .foregroundColor(.ubTextPrimary)
                
                Text("You earned \(points) points")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
            }
            
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
                
                Button("Play Again", action: onPlayAgain)
                    .font(Theme.fontHeadline)
                    .foregroundColor(.ubPrimary)
                    .padding()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
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
