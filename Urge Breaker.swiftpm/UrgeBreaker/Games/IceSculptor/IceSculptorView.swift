import SwiftUI

struct IceSculptorView: View {
    @StateObject var viewModel: IceSculptorViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.7, green: 0.9, blue: 1.0), Color(red: 0.85, green: 0.95, blue: 1.0)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("REVEALED").font(Theme.fontCaption).foregroundColor(.blue.opacity(0.7))
                        Text("\(Int(viewModel.revealProgress * 100))%")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("SHAPE").font(Theme.fontCaption).foregroundColor(.blue.opacity(0.7))
                        Text("???")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                }.padding(.horizontal, 30)
                
                Spacer()
                
                // Ice Grid
                GeometryReader { geo in
                    let size = min(geo.size.width - 40, geo.size.height)
                    let cellSize = size / CGFloat(viewModel.iceGrid.count)
                    
                    ZStack {
                        // Hidden shape layer (underneath)
                        ForEach(0..<viewModel.iceGrid.count, id: \.self) { row in
                            ForEach(0..<viewModel.iceGrid[row].count, id: \.self) { col in
                                Rectangle()
                                    .fill(Color.cyan.opacity(0.15))
                                    .frame(width: cellSize, height: cellSize)
                                    .position(x: CGFloat(col) * cellSize + cellSize / 2,
                                            y: CGFloat(row) * cellSize + cellSize / 2)
                            }
                        }
                        
                        // Ice layer
                        ForEach(0..<viewModel.iceGrid.count, id: \.self) { row in
                            ForEach(0..<viewModel.iceGrid[row].count, id: \.self) { col in
                                if viewModel.iceGrid[row][col] {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(colors: [.white.opacity(0.9), .cyan.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .frame(width: cellSize - 1, height: cellSize - 1)
                                        .position(x: CGFloat(col) * cellSize + cellSize / 2,
                                                y: CGFloat(row) * cellSize + cellSize / 2)
                                }
                            }
                        }
                    }
                    .frame(width: size, height: size)
                    .background(Color.blue.opacity(0.05))
                    .cornerRadius(16)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                viewModel.chipArea(at: value.location, cellSize: cellSize)
                            }
                    )
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Text("Drag to carve the ice").font(Theme.fontCaption).foregroundColor(.blue.opacity(0.5))
                    .padding(.bottom, 40)
            }
            
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "snowflake").font(.system(size: 48)).foregroundColor(.cyan)
                        Text("Shape Revealed!").font(Theme.fontTitle).foregroundColor(.white)
                        Text("A beautiful \(viewModel.shapeName)").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .onAppear { viewModel.startGame() }
    }
}
