import SwiftUI

struct SummitClimbView: View {
    @StateObject var viewModel: SummitClimbViewModel
    
    var body: some View {
        ZStack {
            // Mountain sky gradient — shifts as you climb
            LinearGradient(
                colors: [
                    Color(red: 0.3 - Double(viewModel.altitude) * 0.2,
                          green: 0.35 - Double(viewModel.altitude) * 0.15,
                          blue: 0.5 + Double(viewModel.altitude) * 0.3),
                    Color(red: 0.6, green: 0.7, blue: 0.85)
                ],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ALTITUDE").font(Theme.fontCaption).foregroundColor(.white.opacity(0.7))
                        Text("\(Int(viewModel.altitude * 100))%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("WIND").font(Theme.fontCaption).foregroundColor(.white.opacity(0.7))
                        Text(viewModel.isSlipping ? "⚠️ Strong" : "🍃 Calm")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.isSlipping ? .red : .green)
                    }
                }.padding(.horizontal, 30)
                
                Spacer()
                
                // Mountain path
                ZStack {
                    // Mountain shape
                    MountainPath()
                        .fill(
                            LinearGradient(colors: [Color.gray.opacity(0.4), Color.white.opacity(0.2)],
                                         startPoint: .bottom, endPoint: .top)
                        )
                        .frame(width: 300, height: 400)
                    
                    // Snow cap
                    MountainPath()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 300, height: 400)
                        .mask(
                            Rectangle().frame(height: 80).offset(y: -160)
                        )
                    
                    // Climber
                    VStack(spacing: 2) {
                        Image(systemName: "figure.hiking")
                            .font(.system(size: 28))
                            .foregroundColor(.orange)
                        if viewModel.isSlipping {
                            Text("!")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                    .offset(
                        x: viewModel.climberOffset,
                        y: 180 - viewModel.altitude * 360
                    )
                    .animation(.spring(response: 0.3), value: viewModel.altitude)
                    
                    // Flag at summit
                    Image(systemName: "flag.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                        .offset(y: -185)
                }
                
                // Altitude progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(colors: [.green, .yellow, .orange],
                                             startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * viewModel.altitude, height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Spacer()
                
                Text("Hold your phone still to climb")
                    .font(Theme.fontCaption).foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 10)
                Text("Tap to steady yourself")
                    .font(Theme.fontCaption).foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 40)
            }
            
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "mountain.2.fill").font(.system(size: 48)).foregroundColor(.yellow)
                        Text("Summit Reached!").font(Theme.fontTitle).foregroundColor(.white)
                        Text("Steady hands. Steady mind.").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { viewModel.tapToSteady() }
        .onAppear { viewModel.startGame() }
    }
}

struct MountainPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
