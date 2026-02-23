import SwiftUI

struct UrgeWaveView: View {
    var intensity: Double // 1.0 to 10.0 (or whatever scale)
    var color: Color = .ubPrimary
    
    @State private var phase: Double = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let speed = 2.0 + (intensity * 0.5)
                let amplitude = 10.0 + (intensity * 5.0)
                let frequency = 0.02 + (intensity * 0.005)
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height))
                
                for x in stride(from: 0, through: size.width, by: 1) {
                    let y = size.height * 0.7 + sin(x * frequency + time * speed) * amplitude
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                path.addLine(to: CGPoint(x: size.width, y: size.height))
                path.closeSubpath()
                
                context.fill(path, with: .color(color.opacity(0.3)))
                
                // Second layer for depth
                var path2 = Path()
                path2.move(to: CGPoint(x: 0, y: size.height))
                for x in stride(from: 0, through: size.width, by: 1) {
                    let y = size.height * 0.75 + sin(x * (frequency * 0.8) + time * (speed * 0.7) + 1.0) * (amplitude * 1.2)
                    path2.addLine(to: CGPoint(x: x, y: y))
                }
                path2.addLine(to: CGPoint(x: size.width, y: size.height))
                path2.closeSubpath()
                
                context.fill(path2, with: .color(color.opacity(0.2)))
            }
        }
    }
}

struct UrgeWaveView_Previews: PreviewProvider {
    static var previews: some View {
        UrgeWaveView(intensity: 5.0)
            .frame(height: 300)
    }
}
