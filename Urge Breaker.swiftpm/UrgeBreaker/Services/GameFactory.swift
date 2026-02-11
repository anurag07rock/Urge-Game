import SwiftUI

@MainActor
class GameFactory {
    @ViewBuilder
    static func createView(for gameType: GameType, intensity: Int = 1, onComplete: @escaping () -> Void) -> some View {
        switch gameType {
        case .breathing:
            BreathingView(viewModel: BreathingViewModel(onComplete: onComplete))
        case .tapChallenge:
            TapView(viewModel: TapViewModel(onComplete: onComplete))
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
        }
    }
}
