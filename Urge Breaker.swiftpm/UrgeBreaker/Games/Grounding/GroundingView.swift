import SwiftUI

struct GroundingView: View {
    @StateObject var viewModel: GroundingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            if viewModel.currentStageIndex < viewModel.stages.count {
                let stage = viewModel.stages[viewModel.currentStageIndex]
                
                VStack(spacing: 40) {
                    // Header
                    HStack {
                        GameBackButton(onDismiss: {
                            viewModel.endGame()
                            dismiss()
                        })
                        .padding(.leading, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                            Text("\(Int(viewModel.timeRemaining))s")
                                .monospacedDigit()
                        }
                        .font(Theme.fontHeadline)
                        .foregroundColor(.ubTextPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.ubSurface)
                        .cornerRadius(Theme.layoutRadius)
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    
                    // Main Content
                    VStack(spacing: 24) {
                        Image(systemName: stage.icon)
                            .font(.system(size: 80))
                            .foregroundColor(.ubPrimary)
                            .padding(40)
                            .background(Circle().fill(Color.ubSurface))
                            .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 5)
                            .transition(.scale.combined(with: .opacity))
                            .id("icon-\(viewModel.currentStageIndex)")
                        
                        Text(stage.title)
                            .font(Theme.fontTitle)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.ubTextPrimary)
                            .id("title-\(viewModel.currentStageIndex)")
                            .padding(.horizontal, 24)
                        
                        // Progress Dots
                        HStack(spacing: 12) {
                            ForEach(1...stage.count, id: \.self) { index in
                                Circle()
                                    .fill(index <= viewModel.currentItemCount ? Color.ubPrimary : Color.ubSubtleBackground)
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(index == viewModel.currentItemCount ? 1.3 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.currentItemCount)
                            }
                        }
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    // Confirmation Button
                    Button(action: {
                        withAnimation {
                            viewModel.confirmItem()
                        }
                    }) {
                        Text("I Found One")
                            .font(Theme.fontHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.ubPrimary)
                            .cornerRadius(Theme.layoutRadius)
                            .shadow(color: Color.ubPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}
