import SwiftUI

struct TapView: View {
    @StateObject var viewModel: TapViewModel
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    GameBackButton(onDismiss: {
                        viewModel.endGame()
                    })
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    Spacer()
                }
                
                Spacer()
                
                // Center Content
                VStack(spacing: 40) {
                    // Main Tap Button / Counter
                    Button(action: {
                        viewModel.tap()
                    }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.ubPrimary, .ubPrimary.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 260, height: 260)
                            .overlay(
                                VStack(spacing: 4) {
                                    if #available(iOS 17.0, *) {
                                        Text("\(viewModel.score)")
                                            .font(.system(size: 80, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .contentTransition(.numericText())
                                            .animation(.snappy, value: viewModel.score)
                                    } else {
                                        Text("\(viewModel.score)")
                                            .font(.system(size: 80, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    Text("TAPS")
                                        .font(Theme.fontCaption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                        .tracking(2)
                                }
                            )
                            .shadow(color: Color.ubPrimary.opacity(0.4), radius: 20, x: 0, y: 10)
                            .scaleEffect(viewModel.buttonScale)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Timer Below Counter
                    HStack(spacing: 8) {
                        Image(systemName: "stopwatch.fill")
                        Text("\(Int(viewModel.timeRemaining))s")
                            .monospacedDigit()
                    }
                    .font(Theme.fontTitle)
                    .foregroundColor(.ubTextPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.ubSurface)
                    .cornerRadius(Theme.layoutRadius)
                }
                
                Spacer()
                
                Text("Tap as fast as you can!")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
        .navigationBarHidden(true)
    }
}
