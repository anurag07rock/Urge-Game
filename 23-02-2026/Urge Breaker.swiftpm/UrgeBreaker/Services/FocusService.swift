import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

@MainActor
class FocusService: ObservableObject {
    static let shared = FocusService()
    
    private let store = ManagedSettingsStore()
    
    @Published var isAuthorized: Bool = false
    @Published var selection = FamilyActivitySelection() {
        didSet {
            // Save selection to persistence if needed
        }
    }
    
    private init() {
        // Authorization check
        self.isAuthorized = (AuthorizationCenter.shared.authorizationStatus == .approved)
    }
    
    func requestAuthorization() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                DispatchQueue.main.async {
                    self.isAuthorized = true
                }
            } catch {
                print("Failed to authorize Screen Time: \(error)")
            }
        }
    }
    
    func startShielding() {
        guard isAuthorized else { return }
        
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        
        if applications.isEmpty && categories.isEmpty { return }
        
        store.shield.applications = applications
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categories)
    }
    
    func stopShielding() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}
