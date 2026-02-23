import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding_v3") private var hasCompletedOnboarding: Bool = false
    @EnvironmentObject var urgeService: UrgeService
    
    var body: some View {
        ZStack {
            if hasCompletedOnboarding {
                HomeView(urgeService: urgeService)
                    .transition(.opacity)
            } else {
                OnboardingView(onFinished: {
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                })
                .environmentObject(urgeService)
                .transition(.opacity)
            }
        }
        .animation(.default, value: hasCompletedOnboarding)
    }
}
