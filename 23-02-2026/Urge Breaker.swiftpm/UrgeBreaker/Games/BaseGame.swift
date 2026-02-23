import SwiftUI

@MainActor
protocol BaseGameViewModel: ObservableObject {
    var score: Int { get }
    var timeRemaining: TimeInterval { get }
    var isGameOver: Bool { get }
    var onComplete: (() -> Void)? { get set }
    
    func startGame()
    func endGame()
}
