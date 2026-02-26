import SwiftUI

// MARK: - Calm Background View
/// A subtle, zen background animation combining a slow gradient breathing effect
/// with gently drifting soft blurred shapes. Designed to enhance visual atmosphere
/// without distracting the user or affecting gameplay performance.
///
/// - Fully non-interactive (`allowsHitTesting(false)`)
/// - Respects `accessibilityReduceMotion` (static gradient when enabled)
/// - Pure SwiftUI animations — no Timer / CADisplayLink overhead
/// - All opacities ≤ 0.12 for full UI readability
struct CalmBackgroundView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var animateGradient = false
    @State private var animateOrbs = false
    
    // Soft floating orbs configuration
    private let orbs: [OrbConfig] = [
        OrbConfig(color: .ubPrimary,   size: 180, x: -100, y: -220, driftY: 30,  duration: 14),
        OrbConfig(color: .ubSecondary, size: 140, x:  120, y:  180, driftY: -25, duration: 16),
        OrbConfig(color: .ubPrimary,   size: 100, x:  -60, y:   80, driftY: 20,  duration: 12),
        OrbConfig(color: .ubAccent,    size: 120, x:   80, y: -120, driftY: -35, duration: 18),
        OrbConfig(color: .ubSecondary, size: 90,  x: -140, y:  260, driftY: 25,  duration: 15),
        OrbConfig(color: .ubPrimary,   size: 110, x:  150, y:   40, driftY: -20, duration: 13),
    ]
    
    var body: some View {
        ZStack {
            // Layer 1: Slow gradient breathing
            LinearGradient(
                colors: [
                    Color.ubPrimary.opacity(animateGradient ? 0.08 : 0.04),
                    Color.ubSecondary.opacity(animateGradient ? 0.06 : 0.03),
                    Color.ubPrimary.opacity(animateGradient ? 0.04 : 0.08)
                ],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            
            // Layer 2: Floating soft shapes
            ForEach(orbs.indices, id: \.self) { index in
                let orb = orbs[index]
                Circle()
                    .fill(orb.color)
                    .frame(width: orb.size, height: orb.size)
                    .blur(radius: orb.size * 0.4)
                    .opacity(0.06)
                    .offset(
                        x: orb.x,
                        y: orb.y + (animateOrbs ? orb.driftY : 0)
                    )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            guard !reduceMotion else { return }
            
            withAnimation(
                .easeInOut(duration: 10)
                .repeatForever(autoreverses: true)
            ) {
                animateGradient = true
            }
            
            withAnimation(
                .easeInOut(duration: 14)
                .repeatForever(autoreverses: true)
            ) {
                animateOrbs = true
            }
        }
    }
}

// MARK: - Orb Configuration
private struct OrbConfig {
    let color: Color
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let driftY: CGFloat
    let duration: Double
}
