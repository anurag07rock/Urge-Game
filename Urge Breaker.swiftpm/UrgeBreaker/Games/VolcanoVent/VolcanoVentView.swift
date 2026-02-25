import SwiftUI

struct VolcanoVentView: View {
    @StateObject var viewModel: VolcanoVentViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.94, green: 0.27, blue: 0.27), Color(red: 0.99, green: 0.65, blue: 0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Lava particles
            if !reduceMotion {
                ForEach(viewModel.particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .position(particle.position)
                }
            }
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ERUPTIONS")
                            .font(Theme.fontCaption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(viewModel.eruptionCount) / 3")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TIME")
                            .font(Theme.fontCaption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Int(viewModel.timeRemaining))s")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Volcano + Pressure Ring
                ZStack {
                    // Volcano shape
                    VolcanoShape()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.4, green: 0.2, blue: 0.1), Color(red: 0.3, green: 0.15, blue: 0.08)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 200, height: 160)
                        .offset(y: 60)
                    
                    // Pressure ring
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 16)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: min(viewModel.pressure, 1.0))
                            .stroke(
                                viewModel.isOverflow ? Color.red : Color.orange,
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.05), value: viewModel.pressure)
                        
                        // Center icon
                        VStack(spacing: 4) {
                            Image(systemName: viewModel.isErupting ? "flame.fill" : "mountain.2.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.white)
                                .scaleEffect(viewModel.isErupting ? 1.3 : 1.0)
                                .animation(.spring(response: 0.3), value: viewModel.isErupting)
                            
                            if !viewModel.isErupting && !viewModel.showCompletion {
                                Text(viewModel.isHolding ? "Building..." : "Hold to Build")
                                    .font(Theme.fontCaption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .scaleEffect(viewModel.isErupting ? 1.1 : 1.0)
                    .animation(.spring(response: 0.2), value: viewModel.isErupting)
                }
                
                Spacer()
                
                // Completion overlay
                if viewModel.showCompletion {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white)
                        Text("You released the pressure.")
                            .font(Theme.fontHeadline)
                            .foregroundColor(.white)
                        Text("Stress is temporary.")
                            .font(Theme.fontSubheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .transition(.opacity.combined(with: .scale))
                } else {
                    Text("Hold anywhere to build pressure")
                        .font(Theme.fontHeadline)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 40)
                }
                
                Spacer().frame(height: 40)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !viewModel.isHolding && !viewModel.isErupting {
                        viewModel.startHolding()
                    }
                }
                .onEnded { _ in
                    viewModel.stopHolding()
                }
        )
        .onAppear {
            viewModel.startGame()
        }
        .accessibilityLabel("Volcano Vent game. Hold the screen to build pressure, release to erupt.")
    }
}

// Simple volcano triangle shape
struct VolcanoShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX + 20, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX - 20, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
