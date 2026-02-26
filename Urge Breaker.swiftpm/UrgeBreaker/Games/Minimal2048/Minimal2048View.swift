import SwiftUI

// MARK: - Minimal 2048 View
struct Minimal2048View: View {
    @StateObject var viewModel: Minimal2048ViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            CalmBackgroundView()
            
            VStack(spacing: 20) {
                // Score Header
                scoreHeader
                    .scrollReveal(index: 0)
                
                Spacer()
                
                // Game Board
                gameBoard
                    .scrollReveal(index: 1)
                
                Spacer()
                
                // Controls hint
                Text("Swipe to move tiles")
                    .font(Theme.fontCaption)
                    .foregroundColor(.secondary)
                
                // Restart
                Button(action: { viewModel.startNewGame() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("New Game")
                    }
                    .font(Theme.fontHeadline)
                    .foregroundColor(.ubPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.ubSurface)
                    .cornerRadius(20)
                }
                .buttonStyle(CardPressStyle())
                .padding(.bottom, 20)
            }
            
            // Game Over Overlay
            if viewModel.isGameOver {
                gameOverOverlay
                    .overlayTransition()
            }
        }
        .gesture(swipeGesture)
    }
    
    // MARK: - Score Header
    private var scoreHeader: some View {
        HStack(spacing: 20) {
            VStack(spacing: 2) {
                Text("SCORE")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                SmoothScoreText(
                    value: viewModel.score,
                    font: .system(size: 22, weight: .bold, design: .rounded),
                    color: .ubPrimary
                )
            }
            .frame(width: 90)
            .padding(.vertical, 10)
            .background(Color.ubSurface)
            .cornerRadius(12)
            
            VStack(spacing: 2) {
                Text("BEST")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                SmoothScoreText(
                    value: viewModel.bestScore,
                    font: .system(size: 22, weight: .bold, design: .rounded),
                    color: .ubAccent
                )
            }
            .frame(width: 90)
            .padding(.vertical, 10)
            .background(Color.ubSurface)
            .cornerRadius(12)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Game Board
    private var gameBoard: some View {
        VStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { col in
                        tileView(value: viewModel.grid[row][col])
                    }
                }
            }
        }
        .padding(10)
        .background(Color.ubPrimary.opacity(0.08))
        .cornerRadius(Theme.layoutRadius)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tile View
    private func tileView(value: Int) -> some View {
        let bgColor = tileColor(for: value)
        let fgColor = value <= 4 ? Color.ubTextPrimary : Color.white
        
        return Text(value > 0 ? "\(value)" : "")
            .font(.system(size: tileFontSize(for: value), weight: .bold, design: .rounded))
            .foregroundColor(fgColor)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(bgColor)
            .cornerRadius(10)
            .scaleEffect(value > 0 ? 1.0 : 0.85)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: value)
    }
    
    // MARK: - Game Over Overlay
    private var gameOverOverlay: some View {
        VStack(spacing: 16) {
            Text("Game Over")
                .font(Theme.fontTitle)
                .foregroundColor(.ubTextPrimary)
            
            HStack(spacing: 4) {
                Text("Final Score:")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
                SmoothScoreText(
                    value: viewModel.score,
                    font: Theme.fontHeadline,
                    color: .ubPrimary
                )
            }
            
            Button(action: { viewModel.startNewGame() }) {
                Text("Try Again")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.white)
                    .frame(width: 160, height: 48)
                    .background(Color.ubPrimary)
                    .cornerRadius(24)
            }
            .buttonStyle(CardPressStyle())
        }
        .padding(30)
        .background(Color.ubCardBackground.opacity(0.95))
        .cornerRadius(Theme.layoutRadius)
        .shadow(color: Theme.Shadows.floating, radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Swipe Gesture
    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                
                if abs(horizontal) > abs(vertical) {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        viewModel.move(horizontal > 0 ? .right : .left)
                    }
                } else {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        viewModel.move(vertical > 0 ? .down : .up)
                    }
                }
            }
    }
    
    // MARK: - Tile Styling Helpers
    private func tileColor(for value: Int) -> Color {
        switch value {
        case 0:    return Color.ubPrimary.opacity(0.04)
        case 2:    return Color(red: 0.93, green: 0.89, blue: 0.85)
        case 4:    return Color(red: 0.93, green: 0.88, blue: 0.78)
        case 8:    return Color(red: 0.95, green: 0.69, blue: 0.47)
        case 16:   return Color(red: 0.96, green: 0.58, blue: 0.39)
        case 32:   return Color(red: 0.96, green: 0.49, blue: 0.37)
        case 64:   return Color(red: 0.96, green: 0.37, blue: 0.23)
        case 128:  return Color(red: 0.93, green: 0.81, blue: 0.45)
        case 256:  return Color(red: 0.93, green: 0.80, blue: 0.38)
        case 512:  return Color(red: 0.93, green: 0.78, blue: 0.31)
        case 1024: return Color(red: 0.93, green: 0.76, blue: 0.25)
        case 2048: return Color(red: 0.93, green: 0.74, blue: 0.18)
        default:   return Color(red: 0.24, green: 0.23, blue: 0.20)
        }
    }
    
    private func tileFontSize(for value: Int) -> CGFloat {
        switch value {
        case 0..<10:     return 28
        case 10..<100:   return 24
        case 100..<1000: return 20
        default:         return 16
        }
    }
}
