import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var urgeService: UrgeService // To ensure service is ready if needed, mostly for Architecture consistency
    
    // We bind to a parent state or use a callback to notify App entry to switch views.
    // However, App uses UserDefaults checking.
    // Ideally, we accept a binding or closure to trigger the switch.
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            TabView(selection: $viewModel.currentPageIndex) {
                // Screen 1: Welcome
                OnboardingPageView(
                    title: "Welcome to Urge Breaker",
                    description: "Urge Breaker helps you pause before acting on an urge.",
                    icon: "shield",
                    color: .ubPrimary
                )
                .tag(0)
                
                // Screen 2: How It Works
                OnboardingPageView(
                    title: "How It Works",
                    description: "When you feel an urge, tap the button to play a 30-second reset activity. Small pauses build long-term control.",
                    icon: "timer",
                    color: .ubSuccess
                )
                .tag(1)
                
                // Screen 3: Types of Urges
                OnboardingPageView(
                    title: "Any Urge",
                    description: "From scrolling to stress eating. Intensity 1 (Mild) to 5 (Overwhelming) determines your activity.",
                    icon: "waveform.path.ecg",
                    color: .orange
                )
                .tag(2)
                
                // Screen 4: Game Overview
                OnboardingPageView(
                    title: "5 Reset Tools",
                    description: "Tap for Energy • Memory for Focus • Hold for Control • Breathe for Calm • Grounding for Stability",
                    icon: "gamecontroller.fill",
                    color: .purple
                )
                .tag(3)
                
                // Screen 5: Get Started
                VStack(spacing: 30) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 100))
                        .foregroundColor(.ubPrimary)
                    
                    Text("Ready to Break Urges?")
                        .font(Theme.fontTitle)
                        .multilineTextAlignment(.center)
                    
                    Text("You're stronger than you think.")
                        .font(Theme.fontBody)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        viewModel.completeOnboarding()
                        onFinished()
                    }) {
                        Text("Start Breaking Urges")
                            .font(Theme.fontHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.ubPrimary)
                            .cornerRadius(28)
                            .shadow(color: Color.ubPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 40)
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Navigation Buttons (Skip / Next) logic could go here, 
            // but standard swiping + final button is clean.
            // Let's add a "Continue" button at the bottom for pages 0-3
            
            if viewModel.currentPageIndex < 4 {
                VStack {
                    Spacer()
                    Button("Continue") {
                        withAnimation {
                            viewModel.currentPageIndex += 1
                        }
                    }
                    .font(Theme.fontHeadline)
                    .foregroundColor(.ubPrimary)
                    .padding(.bottom, 60) // Make room for page dots
                }
            }
        }
    }
}
