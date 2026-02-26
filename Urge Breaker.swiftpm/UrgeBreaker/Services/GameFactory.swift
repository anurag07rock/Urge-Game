import SwiftUI

@MainActor
class GameFactory {
    @ViewBuilder
    static func createView(for gameType: GameType, intensity: Int = 1, onComplete: @escaping () -> Void) -> some View {
        switch gameType {
        case .logicCodeBreaker:
            LogicCodeBreakerView(viewModel: LogicCodeBreakerViewModel(onComplete: onComplete))
        case .minimal2048:
            Minimal2048View(viewModel: Minimal2048ViewModel(onComplete: onComplete))
        case .zenSudoku:
            ZenSudokuView(viewModel: ZenSudokuViewModel(onComplete: onComplete))
        case .slidingPuzzle:
            SlidingPuzzleView(viewModel: SlidingPuzzleViewModel(onComplete: onComplete))
        }
    }
}
