import SwiftUI

struct BreathingView: View {
    @StateObject var viewModel: BreathingViewModel
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack {
                // Header without padding top to allow safe area overlay or just use padding
                HStack {
                    // Back Button Top Left
                    GameBackButton(onDismiss: {
                        viewModel.endGame() // Ensure timer stops
                    })
                    
                    Spacer()
                    
                    // Timer Top Right
                    Text("Time: \(Int(viewModel.timeRemaining))")
                        .font(Theme.fontHeadline.monospacedDigit())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Material.thin)
                        .cornerRadius(20)
                }
                .padding()
                
                Spacer()
                
                // Breathing Circle
                ZStack {
                    Circle()
                        .fill(Color.ubAccent.opacity(0.3))
                        .frame(width: 300, height: 300)
                        .scaleEffect(viewModel.scale)
                    
                    Circle()
                        .fill(Color.ubAccent)
                        .frame(width: 250, height: 250)
                        .scaleEffect(viewModel.scale)
                        .overlay(
                            Text(viewModel.phase.rawValue)
                                .font(Theme.fontTitle)
                                .foregroundColor(.white)
                                .transition(.opacity)
                                .id(viewModel.phase)
                        )
                }
                
                Spacer()
                
                Text("Focus on your breath")
                    .font(Theme.fontSubheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .navigationBarHidden(true)
    }
}
