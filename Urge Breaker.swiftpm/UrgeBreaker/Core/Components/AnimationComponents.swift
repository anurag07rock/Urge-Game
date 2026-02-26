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

// MARK: - Scroll Reveal Modifier (fade-in + slide-up on appear)
/// Animates content with a fade-in and upward slide when it appears on screen.
/// Respects `accessibilityReduceMotion` — content appears instantly when enabled.
struct ScrollRevealModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .offset(y: reduceMotion ? 0 : (isVisible ? 0 : 20))
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                if reduceMotion {
                    isVisible = true
                } else {
                    withAnimation(
                        .spring(response: 0.45, dampingFraction: 0.8)
                        .delay(Double(index) * 0.08)
                    ) {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    /// Applies a scroll-reveal animation — fade-in + slide-up with staggered delay.
    func scrollReveal(index: Int = 0) -> some View {
        modifier(ScrollRevealModifier(index: index))
    }
}

// MARK: - Card Press Style (subtle scale + shadow on press)
/// A ButtonStyle that gives cards a premium press-down effect.
/// Respects `accessibilityReduceMotion`.
struct CardPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1.0)
            .shadow(
                color: Color.black.opacity(configuration.isPressed ? 0.02 : 0.06),
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Nav Link Highlight Modifier (animated underline)
/// Adds an animated underline that reveals from the leading edge on appear.
/// Respects `accessibilityReduceMotion`.
struct NavLinkHighlightModifier: ViewModifier {
    let color: Color
    @State private var revealed = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Rectangle()
                        .fill(color)
                        .frame(
                            width: revealed ? geo.size.width : 0,
                            height: 2
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            )
            .onAppear {
                if reduceMotion {
                    revealed = true
                } else {
                    withAnimation(.easeOut(duration: 0.35).delay(0.2)) {
                        revealed = true
                    }
                }
            }
    }
}

extension View {
    /// Adds an animated underline highlight effect, ideal for navigation labels.
    func navLinkHighlight(color: Color = .ubPrimary) -> some View {
        modifier(NavLinkHighlightModifier(color: color))
    }
}

// MARK: - Pulsing Glow Modifier (ambient background pulse)
/// Applies a gentle repeating scale + opacity pulse for ambient glow elements.
/// Respects `accessibilityReduceMotion` — glow stays static when enabled.
struct PulsingGlowModifier: ViewModifier {
    @State private var isPulsing = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing && !reduceMotion ? 1.06 : 1.0)
            .opacity(isPulsing && !reduceMotion ? 0.15 : 0.1)
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 3.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    /// Applies a subtle pulsing glow animation, ideal for background decorative elements.
    func pulsingGlow() -> some View {
        modifier(PulsingGlowModifier())
    }
}

// MARK: - ═══════════════════════════════════════════
// MARK:   WWDC Motion Design System
// MARK: - ═══════════════════════════════════════════

// MARK: - Shake Modifier (controlled error feedback)
/// Applies a brief horizontal shake (150ms) when triggered.
/// Ideal for invalid input, wrong answers, or validation errors.
struct ShakeModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var offset: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { newValue in
                guard newValue, !reduceMotion else { return }
                let duration = 0.075
                withAnimation(.easeInOut(duration: duration)) { offset = -8 }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(.easeInOut(duration: duration)) { offset = 6 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
                    withAnimation(.easeInOut(duration: duration)) { offset = -4 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration * 3) {
                    withAnimation(.easeInOut(duration: duration / 2)) { offset = 0 }
                    trigger = false
                }
            }
    }
}

extension View {
    /// Triggers a brief, controlled shake when the binding becomes true.
    func shake(trigger: Binding<Bool>) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

// MARK: - Success Glow Modifier (radial glow flash)
/// Flashes a soft radial glow around content on success.
struct SuccessGlowModifier: ViewModifier {
    @Binding var trigger: Bool
    var color: Color = .ubSuccess
    @State private var glowOpacity: Double = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(glowOpacity), radius: 20, x: 0, y: 0)
            .shadow(color: color.opacity(glowOpacity * 0.5), radius: 40, x: 0, y: 0)
            .onChange(of: trigger) { newValue in
                guard newValue else { return }
                if reduceMotion {
                    trigger = false
                    return
                }
                withAnimation(.easeIn(duration: 0.15)) { glowOpacity = 0.6 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeOut(duration: 0.35)) { glowOpacity = 0 }
                    trigger = false
                }
            }
    }
}

extension View {
    /// Flashes a soft glow when the binding becomes true.
    func successGlow(trigger: Binding<Bool>, color: Color = .ubSuccess) -> some View {
        modifier(SuccessGlowModifier(trigger: trigger, color: color))
    }
}

// MARK: - Smooth Score Text (animated rolling counter)
/// Displays a number that animates smoothly to its target value.
struct SmoothScoreText: View {
    let value: Int
    var font: Font = .system(size: 22, weight: .bold, design: .rounded)
    var color: Color = .ubPrimary
    
    @State private var displayValue: Int = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Text("\(displayValue)")
                    .font(font)
                    .foregroundColor(color)
                    .contentTransition(.numericText(value: Double(displayValue)))
            } else {
                Text("\(displayValue)")
                    .font(font)
                    .foregroundColor(color)
            }
        }
        .onChange(of: value) { newValue in
            if reduceMotion {
                displayValue = newValue
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    displayValue = newValue
                }
            }
        }
        .onAppear {
            displayValue = value
        }
    }
}

// MARK: - Keypad Button Style (tactile press + highlight)
/// A ButtonStyle for number pads and action keys with a satisfying press feel.
struct KeypadButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Overlay Transition Modifier (scale + opacity entrance)
/// Animates an overlay card from scale 0.92 + transparent to full size.
/// Use on success/game-over/completion overlays for premium entrance.
struct OverlayTransitionModifier: ViewModifier {
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion ? 1.0 : (appeared ? 1.0 : 0.92))
            .opacity(appeared ? 1.0 : 0.0)
            .onAppear {
                if reduceMotion {
                    appeared = true
                } else {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        appeared = true
                    }
                }
            }
    }
}

extension View {
    /// Applies a scale + fade entrance animation, ideal for overlay cards.
    func overlayTransition() -> some View {
        modifier(OverlayTransitionModifier())
    }
}
