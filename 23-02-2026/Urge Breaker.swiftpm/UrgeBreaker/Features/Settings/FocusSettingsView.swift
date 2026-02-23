import SwiftUI
import FamilyControls

struct FocusSettingsView: View {
    @EnvironmentObject var urgeService: UrgeService
    @EnvironmentObject var focusService: FocusService
    @EnvironmentObject var notificationService: NotificationService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingPicker = false
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3.bold())
                    }
                    Spacer()
                    Text("Deep Focus")
                        .font(Theme.fontHeadline)
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding()
                .foregroundColor(.ubPrimary)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Notifications Section
                        SettingsSection(title: "Presence & Care") {
                            Toggle("Proactive Reminders", isOn: Binding(
                                get: { urgeService.currentUser.notificationsEnabled },
                                set: { urgeService.currentUser.notificationsEnabled = $0 }
                            ))
                            .tint(.ubPrimary)
                            
                            Toggle("Wellness Pulse Checks", isOn: Binding(
                                get: { urgeService.currentUser.wellnessRemindersEnabled },
                                set: { urgeService.currentUser.wellnessRemindersEnabled = $0 }
                            ))
                            .tint(.ubPrimary)
                        }
                        
                        // Focus Shield Section
                        SettingsSection(title: "Focus Shield") {
                            Text("Block distracting apps during an active urge to protect your progress.")
                                .font(Theme.fontCaption)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                if focusService.isAuthorized {
                                    showingPicker = true
                                } else {
                                    focusService.requestAuthorization()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "shield.fill")
                                    Text(focusService.isAuthorized ? "Select Apps to Shield" : "Authorize Focus Shield")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.bold())
                                }
                                .foregroundColor(.ubPrimary)
                                .padding(.vertical, 8)
                            }
                            
                            if !focusService.selection.applicationTokens.isEmpty || !focusService.selection.categoryTokens.isEmpty {
                                Text("\(focusService.selection.applicationTokens.count + focusService.selection.categoryTokens.count) targets selected")
                                    .font(Theme.fontCaption)
                                    .foregroundColor(.ubSuccess)
                            }
                            
                            Toggle("Enable Auto-Shielding", isOn: Binding(
                                get: { urgeService.currentUser.focusShieldEnabled },
                                set: { urgeService.currentUser.focusShieldEnabled = $0 }
                            ))
                            .tint(.ubPrimary)
                        }
                        
                        Text("Urge Breaker uses Apple's Screen Time API to help you stay focused. Your data never leaves your device.")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                }
            }
        }
        .familyActivityPicker(isPresented: $showingPicker, selection: $focusService.selection)
        .navigationBarHidden(true)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.fontCaption)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .padding(.leading, 4)
            
            VStack(spacing: 16) {
                content
            }
            .padding()
            .background(Color.ubCardBackground)
            .cornerRadius(Theme.layoutRadius)
            .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 4)
        }
    }
}
