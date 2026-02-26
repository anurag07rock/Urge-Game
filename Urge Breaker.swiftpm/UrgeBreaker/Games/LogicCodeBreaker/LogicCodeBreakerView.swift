import SwiftUI

// MARK: - Logic Code Breaker View
struct LogicCodeBreakerView: View {
    @StateObject var viewModel: LogicCodeBreakerViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var shakeInput = false
    @State private var showSuccessGlow = false
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            CalmBackgroundView()
            
            VStack(spacing: 16) {
                // Header
                headerView
                    .scrollReveal(index: 0)
                
                // Attempt History
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(viewModel.guesses.enumerated()), id: \.element.id) { index, guess in
                                guessRow(guess)
                                    .id(guess.id)
                                    .scrollReveal(index: index)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .onChange(of: viewModel.guesses.count) { _ in
                        if let last = viewModel.guesses.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Game Over States
                if viewModel.gameState == .won {
                    successOverlay
                        .overlayTransition()
                        .successGlow(trigger: $showSuccessGlow)
                } else if viewModel.gameState == .lost {
                    revealOverlay
                        .overlayTransition()
                }
                
                // Input Area
                if viewModel.gameState == .playing {
                    inputArea
                        .shake(trigger: $shakeInput)
                    numberPad
                }
                
                // Restart
                if viewModel.gameState != .playing {
                    Button(action: { viewModel.restart() }) {
                        Text("Play Again")
                            .font(Theme.fontHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.ubPrimary)
                            .cornerRadius(25)
                    }
                    .buttonStyle(CardPressStyle())
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    .scrollReveal(index: 0)
                }
            }
        }
        .onChange(of: viewModel.gameState) { state in
            if state == .lost {
                shakeInput = true
            } else if state == .won {
                showSuccessGlow = true
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 4) {
            Text("Crack the Code")
                .font(Theme.fontTitle)
                .foregroundColor(.ubTextPrimary)
            
            HStack(spacing: 4) {
                Text("Attempt")
                    .font(Theme.fontCaption)
                    .foregroundColor(.secondary)
                SmoothScoreText(
                    value: viewModel.guesses.count,
                    font: Theme.fontCaption,
                    color: .secondary
                )
                Text("/\(viewModel.maxAttempts)")
                    .font(Theme.fontCaption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Guess Row
    private func guessRow(_ guess: LogicCodeBreakerViewModel.Guess) -> some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { i in
                VStack(spacing: 4) {
                    Text("\(guess.digits[i])")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.ubTextPrimary)
                        .frame(width: 52, height: 52)
                        .background(feedbackColor(guess.feedback[i]).opacity(0.15))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(feedbackColor(guess.feedback[i]), lineWidth: 2)
                        )
                    
                    Text(feedbackEmoji(guess.feedback[i]))
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(Color.ubCardBackground)
        .cornerRadius(16)
        .shadow(color: Theme.Shadows.card, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Input Area
    private var inputArea: some View {
        HStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { i in
                let isFilled = i < viewModel.currentInput.count
                Text(isFilled ? "\(viewModel.currentInput[i])" : "")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.ubPrimary)
                    .frame(width: 60, height: 60)
                    .background(Color.ubSurface)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isFilled ? Color.ubPrimary : Color.secondary.opacity(0.3),
                                lineWidth: isFilled ? 2.5 : 1.5
                            )
                            .animation(.easeInOut(duration: 0.2), value: isFilled)
                    )
                    .scaleEffect(isFilled && !reduceMotion ? 1.0 : (isFilled ? 1.0 : 0.98))
                    .animation(.easeInOut(duration: 0.15), value: isFilled)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Number Pad
    private var numberPad: some View {
        VStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(1...3, id: \.self) { col in
                        let digit = row * 3 + col
                        Button(action: { viewModel.addDigit(digit) }) {
                            Text("\(digit)")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(.ubTextPrimary)
                                .frame(width: 64, height: 48)
                                .background(Color.ubSurface)
                                .cornerRadius(12)
                        }
                        .buttonStyle(KeypadButtonStyle())
                        .accessibilityLabel("Digit \(digit)")
                    }
                }
            }
            
            HStack(spacing: 10) {
                // Delete
                Button(action: { viewModel.removeLastDigit() }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.ubDanger)
                        .frame(width: 64, height: 48)
                        .background(Color.ubSurface)
                        .cornerRadius(12)
                }
                .buttonStyle(KeypadButtonStyle())
                .accessibilityLabel("Delete last digit")
                
                Spacer().frame(width: 64)
                
                // Submit
                Button(action: { viewModel.submitGuess() }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(viewModel.currentInput.count == 3 ? .ubSuccess : .secondary)
                        .frame(width: 64, height: 48)
                        .background(Color.ubSurface)
                        .cornerRadius(12)
                }
                .buttonStyle(KeypadButtonStyle())
                .disabled(viewModel.currentInput.count != 3)
                .accessibilityLabel("Submit guess")
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 16)
    }
    
    // MARK: - Success Overlay
    private var successOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundColor(.ubSuccess)
            Text("Code Cracked!")
                .font(Theme.fontTitle)
                .foregroundColor(.ubSuccess)
            Text("Solved in \(viewModel.guesses.count) attempt\(viewModel.guesses.count == 1 ? "" : "s")")
                .font(Theme.fontSubheadline)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color.ubCardBackground)
        .cornerRadius(Theme.layoutRadius)
        .shadow(color: Theme.Shadows.floating, radius: 15, x: 0, y: 8)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Reveal Overlay
    private var revealOverlay: some View {
        VStack(spacing: 12) {
            Text("The code was:")
                .font(Theme.fontSubheadline)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                ForEach(Array(viewModel.secretCode.enumerated()), id: \.offset) { index, digit in
                    Text("\(digit)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.ubPrimary)
                        .frame(width: 52, height: 52)
                        .background(Color.ubPrimary.opacity(0.1))
                        .cornerRadius(12)
                        .scrollReveal(index: index)
                }
            }
            Text("Better luck next time!")
                .font(Theme.fontCaption)
                .foregroundColor(.secondary)
        }
        .padding(24)
        .background(Color.ubCardBackground)
        .cornerRadius(Theme.layoutRadius)
        .shadow(color: Theme.Shadows.floating, radius: 15, x: 0, y: 8)
        .padding(.horizontal, 40)
    }
    
    // MARK: - Helpers
    private func feedbackColor(_ f: LogicCodeBreakerViewModel.DigitFeedback) -> Color {
        switch f {
        case .correctPosition: return .ubSuccess
        case .wrongPosition: return .ubAccent
        case .notPresent: return .ubDanger
        }
    }
    
    private func feedbackEmoji(_ f: LogicCodeBreakerViewModel.DigitFeedback) -> String {
        switch f {
        case .correctPosition: return "✅"
        case .wrongPosition: return "🔄"
        case .notPresent: return "❌"
        }
    }
}
