import SwiftUI

struct MemoryView: View {
    @StateObject var viewModel: MemoryViewModel
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    GameBackButton(onDismiss: {
                        viewModel.endGame()
                    })
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        // Timer
                        HStack(spacing: 4) {
                            Image(systemName: "stopwatch")
                            Text("\(Int(viewModel.timeRemaining))")
                                .monospacedDigit()
                        }
                        .font(Theme.fontHeadline)
                        
                        // Score
                        Text("Score: \(viewModel.score)")
                            .font(Theme.fontHeadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.ubSurface)
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                Spacer()
                
                // Display Area
                RoundedRectangle(cornerRadius: 24)
                    .fill(viewModel.flashColor ?? Color.ubSurface)
                    .frame(width: 220, height: 220)
                    .overlay(
                        Text(viewModel.message)
                            .font(Theme.fontHeadline)
                            .foregroundColor(.ubTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding()
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                    .padding()
                
                Spacer()
                
                // Controls
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(MemoryGame.colors, id: \.self) { color in
                        Button(action: {
                            viewModel.playerTapped(color: color)
                        }) {
                            Circle()
                                .fill(color)
                                .frame(height: 80)
                                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
                                .opacity(viewModel.isShowingSequence ? 0.5 : 1.0)
                        }
                        .disabled(viewModel.isShowingSequence)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .navigationBarHidden(true)
    }
}
