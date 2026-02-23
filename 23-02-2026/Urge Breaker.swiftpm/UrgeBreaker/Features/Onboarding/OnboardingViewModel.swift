import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    private let persistence = PersistenceService.shared
    
    func completeOnboarding() {
        persistence.hasCompletedOnboarding = true
    }
}
