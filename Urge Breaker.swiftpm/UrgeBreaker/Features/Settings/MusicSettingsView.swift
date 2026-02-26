import SwiftUI

// MARK: - Music Settings View
/// Minimal, elegant controls for background music.
struct MusicSettingsView: View {
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.presentationMode) var presentationMode
    
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
                    Text("Focus Music")
                        .font(Theme.fontHeadline)
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding()
                .foregroundColor(.ubPrimary)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Music Toggle
                        SettingsSection(title: "Music") {
                            Toggle("Background Music", isOn: $audioManager.isMusicEnabled)
                                .tint(.ubPrimary)
                                .accessibilityLabel("Toggle background music")
                        }
                        .scrollReveal(index: 0)
                        
                        // Theme Selector
                        if audioManager.isMusicEnabled {
                            SettingsSection(title: "Ambient Theme") {
                                ForEach(AudioManager.SoundTheme.allCases) { theme in
                                    themeRow(theme)
                                }
                            }
                            .scrollReveal(index: 1)
                            
                            // Volume
                            SettingsSection(title: "Volume") {
                                HStack(spacing: 12) {
                                    Image(systemName: "speaker.fill")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14))
                                    
                                    Slider(value: $audioManager.volume, in: 0.05...1.0, step: 0.05)
                                        .tint(.ubPrimary)
                                        .accessibilityLabel("Music volume")
                                    
                                    Image(systemName: "speaker.wave.3.fill")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14))
                                }
                            }
                            .scrollReveal(index: 2)
                        }
                        
                        // Info
                        Text("Music uses procedurally generated ambient tones.\nNo audio files required. Respects system silent mode.")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .scrollReveal(index: 3)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Theme Row
    private func themeRow(_ theme: AudioManager.SoundTheme) -> some View {
        Button(action: {
            audioManager.switchTheme(to: theme)
        }) {
            HStack(spacing: 14) {
                Image(systemName: theme.icon)
                    .font(.system(size: 18))
                    .foregroundColor(audioManager.currentTheme == theme ? .ubPrimary : .secondary)
                    .frame(width: 28)
                
                Text(theme.rawValue)
                    .font(Theme.fontBody)
                    .foregroundColor(.ubTextPrimary)
                
                Spacer()
                
                if audioManager.currentTheme == theme {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.ubPrimary)
                        .font(.system(size: 18))
                }
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.rawValue) theme\(audioManager.currentTheme == theme ? ", selected" : "")")
    }
}
