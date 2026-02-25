import SwiftUI

struct ThunderJarView: View {
    @StateObject var viewModel: ThunderJarViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.05, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.35)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            // Lightning flashes
            if viewModel.shakeIntensity > 0.3 {
                Color.white.opacity(viewModel.shakeIntensity * 0.15).ignoresSafeArea()
            }
            
            // Explosion particles
            ForEach(viewModel.particles, id: \.id) { p in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: CGFloat.random(in: 6...16))
                    .offset(x: p.x, y: p.y)
                    .opacity(p.opacity)
            }
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                // Crack meter
                HStack {
                    Text("PRESSURE").font(Theme.fontCaption).foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(Int(viewModel.crackLevel * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.crackLevel > 0.8 ? .red : .yellow)
                }
                .padding(.horizontal, 30)
                
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 12)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(colors: [.yellow, .orange, .red],
                                             startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * viewModel.crackLevel, height: 12)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                
                Spacer()
                
                // Jar
                if !viewModel.isShattered {
                    ZStack {
                        // Glow
                        Circle()
                            .fill(Color.yellow.opacity(0.2 + viewModel.crackLevel * 0.3))
                            .frame(width: 250, height: 250)
                            .blur(radius: 30)
                        
                        // Jar body
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(colors: [
                                    Color.yellow.opacity(0.3 + viewModel.crackLevel * 0.4),
                                    Color.purple.opacity(0.3)
                                ], startPoint: .top, endPoint: .bottom)
                            )
                            .frame(width: 140, height: 180)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.yellow.opacity(0.6), lineWidth: 3)
                            )
                            .overlay(
                                // Cracks
                                CrackOverlay(level: viewModel.crackLevel)
                                    .stroke(Color.yellow, lineWidth: 2)
                                    .frame(width: 130, height: 170)
                            )
                        
                        // Lightning bolt icon
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow, radius: 10)
                    }
                    .scaleEffect(viewModel.jarScale)
                    .onTapGesture { viewModel.tapToShake() }
                } else {
                    // Shattered state
                    VStack(spacing: 16) {
                        Image(systemName: "bolt.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.yellow)
                        Text("SHATTERED!")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                if viewModel.showCompletion {
                    VStack(spacing: 8) {
                        Text("The tension is released.").font(Theme.fontHeadline).foregroundColor(.white)
                        Text("You are stronger than the storm.").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }.padding(.bottom, 40)
                } else {
                    Text("Shake your phone to crack the jar!")
                        .font(Theme.fontCaption).foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 20)
                    Text("Or tap the jar")
                        .font(Theme.fontCaption).foregroundColor(.white.opacity(0.4))
                        .padding(.bottom, 40)
                }
            }
        }
        .onAppear { viewModel.startGame() }
    }
}

struct CrackOverlay: Shape {
    var level: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard level > 0.1 else { return path }
        
        // Generate cracks based on level
        let numCracks = Int(level * 5)
        for i in 0..<numCracks {
            let startX = rect.midX + CGFloat.random(in: -20...20)
            let startY = rect.midY + CGFloat.random(in: -30...30)
            path.move(to: CGPoint(x: startX, y: startY))
            let endX = startX + CGFloat.random(in: -40...40)
            let endY = startY + CGFloat.random(in: -40...40)
            path.addLine(to: CGPoint(x: endX, y: endY))
            if i > 1 {
                path.addLine(to: CGPoint(x: endX + CGFloat.random(in: -20...20), y: endY + CGFloat.random(in: -20...20)))
            }
        }
        return path
    }
}
