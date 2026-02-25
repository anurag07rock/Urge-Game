import SwiftUI

struct MirrorMindView: View {
    @StateObject var viewModel: MirrorMindViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                HStack {
                    Text("Round \(viewModel.round) / 5")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    if viewModel.isShowingSequence {
                        Text("Watch...")
                            .font(Theme.fontCaption)
                            .foregroundColor(.cyan.opacity(0.7))
                    } else if !viewModel.showCompletion {
                        Text("Your turn")
                            .font(Theme.fontCaption)
                            .foregroundColor(.green.opacity(0.7))
                    }
                }.padding(.horizontal, 30)
                
                if !viewModel.feedback.isEmpty {
                    Text(viewModel.feedback)
                        .font(Theme.fontSubheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 10)
                }
                
                Spacer()
                
                // 2x2 Quadrant grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        Button(action: { viewModel.tapQuadrant(index) }) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    viewModel.activeQuadrant == index
                                        ? viewModel.quadrantColors[index]
                                        : viewModel.quadrantColors[index].opacity(0.15)
                                )
                                .frame(height: 150)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(viewModel.quadrantColors[index].opacity(0.3), lineWidth: 1)
                                )
                                .shadow(
                                    color: viewModel.activeQuadrant == index
                                        ? viewModel.quadrantColors[index].opacity(0.5) : .clear,
                                    radius: 20
                                )
                        }
                        .disabled(viewModel.isShowingSequence)
                        .accessibilityLabel("Quadrant \(index + 1)")
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Text("No timer. No pressure. Just presence.")
                    .font(Theme.fontCaption)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 40)
            }
            
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "circle.grid.2x2.fill").font(.system(size: 48)).foregroundColor(.cyan)
                        Text("Mind Mirrored").font(Theme.fontTitle).foregroundColor(.white)
                        Text("You found stillness in the pattern.").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .onAppear { viewModel.startGame() }
    }
}
