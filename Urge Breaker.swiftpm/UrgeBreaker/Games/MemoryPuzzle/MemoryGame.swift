import SwiftUI

struct MemoryGame {
    struct Item: Identifiable, Equatable {
        let id = UUID()
        let color: Color
    }
    
    static let colors: [Color] = [.red, .blue, .green, .yellow]
    
    static func generateSequence(length: Int) -> [Item] {
        (0..<length).map { _ in Item(color: colors.randomElement()!) }
    }
}
