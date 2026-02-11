import SwiftUI

struct FocusHoldView: View {
    @StateObject var viewModel: FocusHoldViewModel
    @GestureState private var isTouching = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack {
                // Header handled by GameSessionView overlay
                Spacer().frame(height: 60)
                
                // Timer
                HStack {
                    Spacer()
                    Image(systemName: "timer")
                    Text(String(format: "%.1fs", viewModel.timeRemaining))
                        .monospacedDigit()
                }
                .font(Theme.fontHeadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                
                Spacer()
                
                // Main Interactive Circle
                ZStack {
                    // Background Track
                    Circle()
                        .stroke(Color.ubSurface, lineWidth: 20)
                        .frame(width: 280, height: 280)
                    
                    // Progress Ring
                    Circle()
                        .trim(from: 0.0, to: viewModel.holdProgress)
                        .stroke(Color.ubPrimary, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: viewModel.holdProgress)
                    
                    // Touch Target
                    Circle()
                        .fill(viewModel.isHolding ? Color.ubPrimary.opacity(0.2) : Color.ubSurface)
                        .frame(width: 220, height: 220)
                        .scaleEffect(viewModel.circleScale)
                        .overlay(
                            Text(viewModel.feedbackMessage)
                                .font(Theme.fontHeadline)
                                .foregroundColor(viewModel.isHolding ? .ubPrimary : .secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        )
                }
                // Gesture Handling
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !viewModel.isHolding {
                                viewModel.startHolding()
                            }
                        }
                        .onEnded { _ in
                            viewModel.stopHolding()
                        }
                )
                
                Spacer()
                
                Text("Score: \(viewModel.score)")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
            .overlay(
                GameBackButton(onDismiss: {
                    viewModel.endGame()
                    dismiss()
                })
                .padding(.leading, 20)
                .padding(.top, 20),
                alignment: .topLeading
            )
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}
