import SwiftUI

struct UnravelView: View {
    @StateObject var viewModel: UnravelViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.1, blue: 0.2), Color(red: 0.1, green: 0.08, blue: 0.15)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("LAYERS").font(Theme.fontCaption).foregroundColor(.purple.opacity(0.7))
                        Text("\(viewModel.currentLayer) / \(viewModel.layers)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                    }
                    Spacer()
                    // Loop progress
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("UNRAVEL").font(Theme.fontCaption).foregroundColor(.purple.opacity(0.7))
                        Text("\(Int(viewModel.loopProgress * 100))%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                    }
                }.padding(.horizontal, 30)
                
                Spacer()
                
                // Yarn ball
                GeometryReader { geo in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    
                    ZStack {
                        // Glow
                        Circle()
                            .fill(Color.purple.opacity(viewModel.glowIntensity))
                            .frame(width: viewModel.yarnRadius * 2.5, height: viewModel.yarnRadius * 2.5)
                            .blur(radius: 30)
                            .position(center)
                        
                        // Yarn threads (decorative)
                        ForEach(0..<8, id: \.self) { i in
                            let angle = Double(i) * 45
                            Circle()
                                .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                                .frame(width: viewModel.yarnRadius * 1.5, height: viewModel.yarnRadius * 1.5)
                                .rotationEffect(.degrees(angle))
                                .position(center)
                        }
                        
                        // Core yarn ball
                        Circle()
                            .fill(
                                RadialGradient(colors: [.purple.opacity(0.8), .purple.opacity(0.3)],
                                             center: .center, startRadius: 10, endRadius: viewModel.yarnRadius)
                            )
                            .frame(width: viewModel.yarnRadius * 2, height: viewModel.yarnRadius * 2)
                            .position(center)
                        
                        // Glowing thread trail
                        Circle()
                            .trim(from: 0, to: viewModel.loopProgress)
                            .stroke(
                                LinearGradient(colors: [.white, .cyan], startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: viewModel.yarnRadius * 2 + 20, height: viewModel.yarnRadius * 2 + 20)
                            .rotationEffect(.degrees(-90))
                            .position(center)
                            .shadow(color: .cyan, radius: 5)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.updateDrag(at: value.location, center: center)
                            }
                    )
                }
                
                Spacer()
                
                Text("Drag slowly around the yarn to unravel")
                    .font(Theme.fontCaption).foregroundColor(.purple.opacity(0.5))
                    .padding(.bottom, 40)
            }
            
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "lasso").font(.system(size: 48)).foregroundColor(.cyan)
                        Text("Unraveled!").font(Theme.fontTitle).foregroundColor(.white)
                        Text("You broke free with patience.").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .onAppear { viewModel.startGame() }
    }
}
