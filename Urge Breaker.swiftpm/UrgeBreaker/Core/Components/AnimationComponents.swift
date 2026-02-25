import SwiftUI

// MARK: - Shimmer Overlay (for XP bar and buttons)
struct ShimmerOverlay: View {
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [.clear, .white.opacity(0.3), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 80)
            .offset(x: shimmerOffset)
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    shimmerOffset = geo.size.width + 200
                }
            }
        }
        .clipped()
    }
}

// MARK: - Confetti View (for completion cards)
struct ConfettiView: View {
    @State private var particles: [(id: UUID, x: CGFloat, y: CGFloat, color: Color, rotation: Double, scale: CGFloat)] = []
    @State private var animate = false
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles, id: \.id) { p in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(p.color)
                        .frame(width: 8, height: 12)
                        .rotationEffect(.degrees(animate ? p.rotation + 360 : p.rotation))
                        .scaleEffect(animate ? 0 : p.scale)
                        .position(
                            x: animate ? p.x + CGFloat.random(in: -50...50) : geo.size.width / 2,
                            y: animate ? p.y : -20
                        )
                        .opacity(animate ? 0 : 1)
                }
            }
            .onAppear {
                particles = (0..<40).map { _ in
                    (
                        id: UUID(),
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height),
                        color: colors.randomElement() ?? .blue,
                        rotation: Double.random(in: 0...360),
                        scale: CGFloat.random(in: 0.5...1.5)
                    )
                }
                withAnimation(.easeOut(duration: 2.5)) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Animated Bar (for weekly chart)
struct AnimatedBar: View {
    let targetHeight: CGFloat
    let color: Color
    let delay: Double
    
    @State private var currentHeight: CGFloat = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(color)
            .frame(height: currentHeight)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        currentHeight = targetHeight
                    }
                }
            }
    }
}

// MARK: - Staggered Appear Modifier
struct StaggeredAppear: ViewModifier {
    let index: Int
    @State private var appeared = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: appeared ? 0 : 30)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppear(index: index))
    }
}

// MARK: - Button Shimmer (for game instruction start button)
struct ButtonShimmer: ViewModifier {
    @State private var shimmerPhase: CGFloat = -1
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.2), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.4)
                    .offset(x: shimmerPhase * geo.size.width)
                    .onAppear {
                        startShimmerCycle()
                    }
                }
                .clipped()
            )
    }
    
    private func startShimmerCycle() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            DispatchQueue.main.async {
                shimmerPhase = -0.5
                withAnimation(.easeInOut(duration: 0.8)) {
                    shimmerPhase = 1.5
                }
            }
        }
    }
}

extension View {
    func buttonShimmer() -> some View {
        modifier(ButtonShimmer())
    }
}

// MARK: - Spring Number (for intensity display)
struct SpringNumber: View {
    let value: Int
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Text("\(value)")
            .scaleEffect(scale)
            .onChange(of: value) { _ in
                withAnimation(.spring(response: 0.2, dampingFraction: 0.4)) {
                    scale = 1.3
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        scale = 1.0
                    }
                }
            }
    }
}
