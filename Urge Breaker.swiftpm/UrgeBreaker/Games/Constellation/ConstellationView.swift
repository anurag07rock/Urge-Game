import SwiftUI

struct ConstellationView: View {
    @StateObject var viewModel: ConstellationViewModel
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Deep indigo night sky gradient
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.09, blue: 0.16), Color(red: 0.12, green: 0.23, blue: 0.37)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Dim background stars
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.1...0.3)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
            
            // Connection lines
            ForEach(viewModel.connections) { connection in
                Path { path in
                    path.move(to: connection.from)
                    path.addLine(to: connection.to)
                }
                .stroke(
                    LinearGradient(colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.6)],
                                   startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .shadow(color: .cyan.opacity(0.5), radius: 4)
            }
            
            // Active drag line
            if let line = viewModel.dragLine {
                Path { path in
                    path.move(to: line.0)
                    path.addLine(to: line.1)
                }
                .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5]))
            }
            
            // Stars
            ForEach(Array(viewModel.stars.enumerated()), id: \.element.id) { index, star in
                ZStack {
                    // Glow
                    if !reduceMotion {
                        Circle()
                            .fill(star.isConnected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.15))
                            .frame(width: 40, height: 40)
                            .blur(radius: 10)
                            .scaleEffect(star.isConnected ? 1.2 : pulseScale)
                    }
                    
                    Circle()
                        .fill(star.isConnected ? Color.cyan : Color.white)
                        .frame(width: star.isConnected ? 16 : 12, height: star.isConnected ? 16 : 12)
                        .shadow(color: star.isConnected ? .cyan : .white, radius: star.isConnected ? 8 : 4)
                    
                    if index == viewModel.selectedStarIndex {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 28, height: 28)
                            .scaleEffect(reduceMotion ? 1.0 : pulseScale)
                    }
                }
                .position(star.position)
                .accessibilityLabel(star.isConnected ? "Connected star" : "Star, tap to select")
            }
            
            VStack {
                Spacer().frame(height: 80)
                
                Text("Connect the Stars")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(viewModel.connections.count) / \(max(viewModel.stars.count - 1, 1)) connections")
                    .font(Theme.fontCaption)
                    .foregroundColor(.white.opacity(0.4))
                
                Spacer()
                
                // Affirming message card
                if viewModel.showMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.title3)
                            .foregroundColor(.cyan)
                        Text(viewModel.currentMessage)
                            .font(Theme.fontBody)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Completion message
                if viewModel.allConnected {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.cyan)
                        Text("You are connected.")
                            .font(Theme.fontTitle)
                            .foregroundColor(.white)
                        Text("Even when it doesn't feel like it.")
                            .font(Theme.fontSubheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .transition(.opacity.combined(with: .scale))
                    .padding(.bottom, 60)
                }
                
                Spacer().frame(height: 40)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if viewModel.selectedStarIndex == nil {
                        // Pick up a star
                        if let index = viewModel.nearestStar(to: value.startLocation) {
                            viewModel.selectStar(at: index)
                        }
                    }
                    viewModel.updateDrag(to: value.location)
                }
                .onEnded { value in
                    if let targetIndex = viewModel.nearestStar(to: value.location),
                       viewModel.selectedStarIndex != nil {
                        viewModel.selectStar(at: targetIndex)
                    } else {
                        viewModel.cancelDrag()
                    }
                }
        )
        .onAppear {
            viewModel.startGame()
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                }
            }
        }
        .accessibilityLabel("Connection Constellation. Connect stars by dragging between them. Each connection reveals an affirming message.")
    }
}
