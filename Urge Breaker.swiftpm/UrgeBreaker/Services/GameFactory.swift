import SwiftUI

@MainActor
class GameFactory {
    @ViewBuilder
    static func createView(for gameType: GameType, intensity: Int = 1, onComplete: @escaping () -> Void) -> some View {
        switch gameType {
        case .breathing:
            BreathingView(viewModel: BreathingViewModel(onComplete: onComplete))
        case .stressSmash:
            StressSmashView(viewModel: StressSmashViewModel(onComplete: onComplete))
        case .focusSniper:
            FocusSniperView(viewModel: FocusSniperViewModel(onComplete: onComplete))
        case .rhythmPulse:
            RhythmPulseView(viewModel: RhythmPulseViewModel(onComplete: onComplete))
        case .memoryPuzzle:
            MemoryView(viewModel: MemoryViewModel(onComplete: onComplete))
        case .grounding:
            if intensity >= 5 {
                Grounding54321View(onComplete: onComplete)
            } else {
                GroundingView(viewModel: GroundingViewModel(onComplete: onComplete))
            }
        case .focusHold:
            FocusHoldView(viewModel: FocusHoldViewModel(onComplete: onComplete))
        case .volcanoVent:
            VolcanoVentView(viewModel: VolcanoVentViewModel(onComplete: onComplete))
        case .bubblePopBlitz:
            BubblePopView(viewModel: BubblePopViewModel(onComplete: onComplete))
        case .connectionConstellation:
            ConstellationView(viewModel: ConstellationViewModel(onComplete: onComplete))
        case .patternBreak:
            PatternBreakView(viewModel: PatternBreakViewModel(onComplete: onComplete))
        case .waveRider:
            WaveRiderView(viewModel: WaveRiderViewModel(onComplete: onComplete))
        case .thunderJar:
            ThunderJarView(viewModel: ThunderJarViewModel(onComplete: onComplete))
        case .iceSculptor:
            IceSculptorView(viewModel: IceSculptorViewModel(onComplete: onComplete))
        case .moodMixer:
            MoodMixerView(viewModel: MoodMixerViewModel(onComplete: onComplete))
        case .rootAndGrow:
            RootAndGrowView(viewModel: RootAndGrowViewModel(onComplete: onComplete))
        case .mirrorMind:
            MirrorMindView(viewModel: MirrorMindViewModel(onComplete: onComplete))
        case .unravel:
            UnravelView(viewModel: UnravelViewModel(onComplete: onComplete))
        case .summitClimb:
            SummitClimbView(viewModel: SummitClimbViewModel(onComplete: onComplete))
        }
    }
}
