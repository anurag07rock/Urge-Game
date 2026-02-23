import SwiftUI

@main
struct UrgeBreakerApp: App {
    @StateObject private var urgeService = UrgeService()
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Reset onboarding state on every launch as requested
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding_v3")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(urgeService)
                .environmentObject(themeManager)
                .environmentObject(NotificationService.shared)
                .environmentObject(FocusService.shared)
                .preferredColorScheme(themeManager.currentScheme)
                .onAppear {
                    Theme.applyAppAppearance()
                }
        }
    }
}
