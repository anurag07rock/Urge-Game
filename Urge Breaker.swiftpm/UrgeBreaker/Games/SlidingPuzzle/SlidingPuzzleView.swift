import SwiftUI

// MARK: - Sliding Puzzle View (3×3 – 8 Puzzle)
struct SlidingPuzzleView: View {
    @StateObject var viewModel: SlidingPuzzleViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var showSuccessGlow = false
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            CalmBackgroundView()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("Sliding Puzzle")
                        .font(Theme.fontTitle)
                        .foregroundColor(.ubTextPrimary)
                    HStack(spacing: 4) {
                        Text("Moves:")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        SmoothScoreText(
                            value: viewModel.moveCount,
                            font: Theme.fontCaption,
                            color: .secondary
                        )
                    }
                }
                .padding(.top, 20)
                .scrollReveal(index: 0)
                
                Spacer()
                
                // Puzzle Grid
                puzzleGrid
                    .scrollReveal(index: 1)
                
                Spacer()
                
                // Hint
                if !viewModel.isSolved {
                    Text("Tap a tile next to the empty space to slide it")
                        .font(Theme.fontCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Restart
                Button(action: { viewModel.startNewGame() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Shuffle")
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
            
            // Solved Overlay
            if viewModel.isSolved {
                solvedOverlay
                    .overlayTransition()
                    .successGlow(trigger: $showSuccessGlow)
            }
        }
        .onChange(of: viewModel.isSolved) { solved in
            if solved { showSuccessGlow = true }
        }
    }
    
    // MARK: - Puzzle Grid
    private var puzzleGrid: some View {
        VStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { col in
                        let index = row * 3 + col
                        let value = viewModel.tiles.indices.contains(index) ? viewModel.tiles[index] : 0
                        
                        tileView(value: value, index: index)
                    }
                }
            }
        }
        .padding(10)
        .background(Color.ubPrimary.opacity(0.06))
        .cornerRadius(Theme.layoutRadius)
        .padding(.horizontal, 50)
    }
    
    // MARK: - Tile View
    private func tileView(value: Int, index: Int) -> some View {
        Group {
            if value == 0 {
                // Empty space
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.ubPrimary.opacity(0.03))
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
            } else {
                Button(action: {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        viewModel.tapTile(at: index)
                    }
                }) {
                    Text("\(value)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(tileGradient(for: value))
                                .shadow(color: Color.ubPrimary.opacity(0.2), radius: 4, x: 0, y: 3)
                        )
                }
                .buttonStyle(KeypadButtonStyle())
                .accessibilityLabel("Tile \(value)")
                .accessibilityHint("Tap to slide")
            }
        }
    }
    
    // MARK: - Solved Overlay
    private var solvedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundColor(.ubSuccess)
            Text("Puzzle Solved!")
                .font(Theme.fontTitle)
                .foregroundColor(.ubSuccess)
            HStack(spacing: 4) {
                Text("Completed in")
                    .font(Theme.fontSubheadline)
                    .foregroundColor(.secondary)
                SmoothScoreText(
                    value: viewModel.moveCount,
                    font: Theme.fontSubheadline,
                    color: .secondary
                )
                Text("moves")
                    .font(Theme.fontSubheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(30)
        .background(Color.ubCardBackground.opacity(0.95))
        .cornerRadius(Theme.layoutRadius)
        .shadow(color: Theme.Shadows.floating, radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Tile Gradient
    private func tileGradient(for value: Int) -> LinearGradient {
        let hue = Double(value - 1) / 8.0 * 0.6
        return LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.5, brightness: 0.8),
                Color(hue: hue, saturation: 0.6, brightness: 0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
