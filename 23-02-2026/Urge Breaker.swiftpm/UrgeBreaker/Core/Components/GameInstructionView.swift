import SwiftUI

struct GameInstructionView: View {
    let gameType: GameType
    var onStart: () -> Void
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: iconName(for: gameType))
                    .font(.system(size: 80))
                    .foregroundColor(.ubPrimary)
                    .padding()
                    .background(Circle().fill(Color.ubSurface))
                    .shadow(radius: 5)
                
                // Title
                Text(gameType.displayName)
                    .font(Theme.fontTitle)
                    .multilineTextAlignment(.center)
                
                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(gameType.instructionSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 16) {
                            Text("\(index + 1)")
                                .font(Theme.fontHeadline)
                                .foregroundColor(.ubPrimary)
                                .frame(width: 24, height: 24)
                                .background(Circle().stroke(Color.ubPrimary, lineWidth: 2))
                            
                            Text(step)
                                .font(.body)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
                .background(Color.ubSurface)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Start Button
                Button(action: onStart) {
                    Text("Start Game")
                        .font(Theme.fontHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.ubPrimary)
                        .cornerRadius(28)
                        .shadow(color: Color.ubPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func iconName(for gameType: GameType) -> String {
        switch gameType {
        case .breathing: return "wind"
        case .stressSmash: return "hand.tap.fill"
        case .focusSniper: return "scope"
        case .rhythmPulse: return "waveform.circle"
        case .memoryPuzzle: return "brain.head.profile"
        case .focusHold: return "circle.circle.fill"
        case .grounding: return "leaf.fill"
        }
    }
}
