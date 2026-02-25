import SwiftUI

struct BubblePopView: View {
    @StateObject var viewModel: BubblePopViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Amber gradient background
            LinearGradient(
                colors: [Color(red: 0.96, green: 0.62, blue: 0.04), Color(red: 0.99, green: 0.91, blue: 0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Bubbles layer
            ForEach(viewModel.bubbles) { bubble in
                BubbleView(bubble: bubble) {
                    viewModel.tapBubble(bubble)
                }
            }
            
            // Sparkle effect
            if let sparklePos = viewModel.showSparkle, !reduceMotion {
                Image(systemName: "sparkle")
                    .font(.system(size: 30))
                    .foregroundColor(.yellow)
                    .position(sparklePos)
                    .transition(.scale.combined(with: .opacity))
            }
            
            VStack {
                Spacer().frame(height: 80)
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("SCORE")
                            .font(Theme.fontCaption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(viewModel.score)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TIME")
                            .font(Theme.fontCaption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Int(viewModel.timeRemaining))s")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(viewModel.timeRemaining < 5 ? .red : .white)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Warning text
                if !viewModel.warningText.isEmpty {
                    Text(viewModel.warningText)
                        .font(Theme.fontHeadline)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .transition(.opacity)
                        .padding(.bottom, 40)
                }
            }
            
            // Countdown overlay
            if viewModel.showCountdown {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Pop the GOOD bubbles!")
                            .font(Theme.fontHeadline)
                            .foregroundColor(.white)
                        Text("Let the bad ones float away")
                            .font(Theme.fontSubheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(viewModel.countdownValue)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }
            }
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}

struct BubbleView: View {
    let bubble: Bubble
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        bubble.isPositive
                            ? Color.white.opacity(0.85)
                            : Color.gray.opacity(0.4)
                    )
                    .frame(width: bubble.size, height: bubble.size)
                    .overlay(
                        Circle()
                            .stroke(
                                bubble.isPositive ? Color.yellow : Color.gray.opacity(0.6),
                                lineWidth: bubble.isPositive ? 3 : 1.5
                            )
                    )
                    .shadow(color: bubble.isPositive ? .yellow.opacity(0.4) : .clear, radius: 8)
                
                Text(bubble.word)
                    .font(.system(size: bubble.size * 0.16, weight: .semibold, design: .rounded))
                    .foregroundColor(bubble.isPositive ? .orange : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(8)
            }
        }
        .position(bubble.position)
        .opacity(bubble.opacity)
        .accessibilityLabel("\(bubble.isPositive ? "Positive" : "Craving") bubble: \(bubble.word)")
    }
}
