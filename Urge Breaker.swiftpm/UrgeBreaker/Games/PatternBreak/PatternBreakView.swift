import SwiftUI

struct PatternBreakView: View {
    @StateObject var viewModel: PatternBreakViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Violet gradient background
            LinearGradient(
                colors: [Color(red: 0.49, green: 0.23, blue: 0.93), Color(red: 0.30, green: 0.11, blue: 0.58)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ROUND")
                            .font(Theme.fontCaption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(viewModel.currentRound) / \(viewModel.totalRounds)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("SCORE")
                            .font(Theme.fontCaption)
                            .foregroundColor(.white.opacity(0.7))
                        ZStack(alignment: .trailing) {
                            Text("\(viewModel.score)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            if viewModel.showFastBonus {
                                Text("+FAST!")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.yellow)
                                    .offset(x: 10, y: -20)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Title
                VStack(spacing: 4) {
                    Text("Which one doesn't belong?")
                        .font(Theme.fontHeadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    if !viewModel.showFeedback.isEmpty {
                        Text(viewModel.showFeedback)
                            .font(Theme.fontBody)
                            .foregroundColor(.green)
                            .transition(.scale)
                    }
                }
                
                Spacer().frame(height: 30)
                
                // 2x2 Grid
                if !viewModel.items.isEmpty {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                            PatternItemCard(
                                item: item,
                                index: index,
                                isCorrectAnswer: viewModel.answeredCorrectly && item.isOddOneOut,
                                isWrongTap: viewModel.wrongIndex == index,
                                isHinted: viewModel.hintQuadrant == index,
                                reduceMotion: reduceMotion
                            ) {
                                viewModel.tapItem(at: index)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                }
                
                Spacer()
                Spacer()
            }
            
            // Countdown overlay
            if viewModel.showCountdown {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Pattern Break")
                            .font(Theme.fontTitle)
                            .foregroundColor(.white)
                        Text("Which one doesn't belong?\nTrust your instincts.")
                            .font(Theme.fontSubheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                        
                        Text("\(viewModel.countdownValue)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }
            }
            
            // Completion overlay
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 48))
                            .foregroundColor(.purple)
                        
                        Text("Pattern Break Complete!")
                            .font(Theme.fontTitle)
                            .foregroundColor(.white)
                        
                        Text("Score: \(viewModel.score) / 10")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                        
                        if viewModel.speedBonusPoints > 0 {
                            Text("Speed bonuses: \(viewModel.speedBonusPoints)")
                                .font(Theme.fontSubheadline)
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                        
                        Text(viewModel.completionMessage)
                            .font(Theme.fontBody)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}

struct PatternItemCard: View {
    let item: PatternItem
    let index: Int
    let isCorrectAnswer: Bool
    let isWrongTap: Bool
    let isHinted: Bool
    let reduceMotion: Bool
    let action: () -> Void
    
    @State private var wobbleAngle: Double = 0
    
    var body: some View {
        Button(action: action) {
            Text(item.display)
                .font(.system(size: 48))
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(cardBackground)
                        .shadow(color: isHinted ? .yellow.opacity(0.5) : .black.opacity(0.2), radius: isHinted ? 10 : 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(borderColor, lineWidth: isHinted ? 3 : isCorrectAnswer ? 3 : 0)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isCorrectAnswer ? 1.1 : 1.0)
        .opacity(isCorrectAnswer ? 0.3 : 1.0)
        .rotationEffect(.degrees(wobbleAngle))
        .onChange(of: isWrongTap) { wrongTap in
            if wrongTap && !reduceMotion {
                withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                    wobbleAngle = 5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.2)) {
                        wobbleAngle = -5
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) {
                        wobbleAngle = 0
                    }
                }
            }
        }
        .animation(.spring(response: 0.3), value: isCorrectAnswer)
        .accessibilityLabel("Grid item \(index + 1): \(item.display)")
    }
    
    private var cardBackground: Color {
        if isWrongTap { return Color.red.opacity(0.2) }
        if isHinted { return Color.yellow.opacity(0.15) }
        return Color.white.opacity(0.15)
    }
    
    private var borderColor: Color {
        if isHinted { return .yellow }
        if isCorrectAnswer { return .green }
        return .clear
    }
}
