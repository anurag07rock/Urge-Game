import SwiftUI

struct FocusSniperView: View {
    @StateObject var viewModel: FocusSniperViewModel
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            // Targets Layer
            ForEach(viewModel.targets) { target in
                TargetView(target: target) {
                    viewModel.tapTarget(target)
                }
            }
            
            VStack {
                Spacer().frame(height: 80)
                
                // Stats
                HStack {
                    VStack(alignment: .leading) {
                        Text("SCORE")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.score)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.ubPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("TIME")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        Text("\(Int(viewModel.timeRemaining))s")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(viewModel.timeRemaining < 5 ? .ubDanger : .ubPrimary)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                Text("Tap the targets, avoid the traps!")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}

struct TargetView: View {
    let target: FocusTarget
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(target.type == .correct ? Color.ubPrimary : Color.ubDanger)
                    .frame(width: target.size, height: target.size)
                    .shadow(color: (target.type == .correct ? Color.ubPrimary : Color.ubDanger).opacity(0.3), radius: 10)
                
                Image(systemName: target.type == .correct ? "target" : "xmark.octagon.fill")
                    .font(.system(size: target.size * 0.5))
                    .foregroundColor(.white)
            }
        }
        .position(target.position)
        .transition(.scale.combined(with: .opacity))
    }
}

enum TargetType {
    case correct
    case trap
}

struct FocusTarget: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var type: TargetType
}
