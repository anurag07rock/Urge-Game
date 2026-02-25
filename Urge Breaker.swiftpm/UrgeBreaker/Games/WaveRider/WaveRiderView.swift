import SwiftUI

struct WaveRiderView: View {
    @StateObject var viewModel: WaveRiderViewModel
    
    var body: some View {
        ZStack {
            // Ocean gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.3, blue: 0.6), Color(red: 0.2, green: 0.6, blue: 0.8)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            // Animated waves
            WaveShape(offset: viewModel.waveOffset, amplitude: 30)
                .fill(Color.white.opacity(0.1))
                .offset(y: 100)
            WaveShape(offset: viewModel.waveOffset + 50, amplitude: 20)
                .fill(Color.white.opacity(0.08))
                .offset(y: 150)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CYCLES").font(Theme.fontCaption).foregroundColor(.white.opacity(0.7))
                        Text("\(viewModel.perfectCycles) / 3")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    // Sync indicator
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("SYNC").font(Theme.fontCaption).foregroundColor(.white.opacity(0.7))
                        Text("\(Int(viewModel.syncScore * 100))%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.syncScore > 0.6 ? .green : .white)
                    }
                }.padding(.horizontal, 30)
                
                Spacer()
                
                // Breathing ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        .frame(width: 120, height: 120)
                    Circle()
                        .stroke(Color.cyan, lineWidth: 4)
                        .frame(width: 120, height: 120)
                        .scaleEffect(viewModel.breathRingScale)
                    Text(viewModel.isInhaling ? "↑" : "↓")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if !viewModel.feedback.isEmpty {
                    Text(viewModel.feedback)
                        .font(Theme.fontHeadline).foregroundColor(.cyan)
                        .transition(.scale)
                }
                
                Text("Swipe up and down to ride the waves")
                    .font(Theme.fontCaption).foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
            }
            
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "water.waves").font(.system(size: 48)).foregroundColor(.cyan)
                        Text("Waves Mastered!").font(Theme.fontTitle).foregroundColor(.white)
                        Text("Your breath controls the ocean.").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    viewModel.updateSwipe(value.location.y, in: UIScreen.main.bounds.height)
                }
        )
        .onAppear { viewModel.startGame() }
    }
}

struct WaveShape: Shape {
    var offset: CGFloat
    var amplitude: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        for x in stride(from: 0, to: rect.width, by: 2) {
            let y = rect.midY + sin((x + offset) * .pi / 100) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
