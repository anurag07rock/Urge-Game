import SwiftUI

struct RhythmPulseView: View {
    @StateObject var viewModel: RhythmPulseViewModel
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack {
                Spacer().frame(height: 80)
                
                // Streak and Timer
                HStack {
                    VStack(alignment: .leading) {
                        Text("FLOW STREAK")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.streak)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.ubPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("SCORE")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.score)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.ubPrimary)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Rhythm Area
                ZStack {
                    // Target Ring (The "Center")
                    Circle()
                        .stroke(Color.ubPrimary.opacity(0.3), lineWidth: 4)
                        .frame(width: 100, height: 100)
                    
                    // The Pulsing Ring
                    Circle()
                        .stroke(Color.ubPrimary, lineWidth: 8)
                        .frame(width: viewModel.pulseSize, height: viewModel.pulseSize)
                        .opacity(viewModel.pulseOpacity)
                    
                    // Tap Indicator
                    Circle()
                        .fill(viewModel.feedbackColor.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(viewModel.feedbackText)
                                .font(Theme.fontHeadline)
                                .foregroundColor(viewModel.feedbackColor)
                        )
                }
                .contentShape(Circle())
                .onTapGesture {
                    viewModel.tap()
                }
                
                Spacer()
                
                Text("Tap when the ring hits the center!")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 60)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}
