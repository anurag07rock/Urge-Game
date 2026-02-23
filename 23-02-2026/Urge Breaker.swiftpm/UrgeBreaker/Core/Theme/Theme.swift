import SwiftUI

struct Theme {
    // Typography
    static let fontLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let fontTitle = Font.system(.title, design: .rounded).weight(.bold)
    static let fontHeadline = Font.system(.headline, design: .rounded).weight(.semibold)
    static let fontSubheadline = Font.system(.subheadline, design: .rounded)
    static let fontBody = Font.system(.body, design: .rounded)
    static let fontCaption = Font.system(.caption, design: .rounded)
    
    // Layout
    static let layoutRadius: CGFloat = 20.0
    static let layoutPadding: CGFloat = 24.0
    
    // Shadows
    struct Shadows {
        static let card = Color.black.opacity(0.05)
        static let floating = Color.black.opacity(0.1)
    }
    
    static func applyAppAppearance() {
        // Global appearance settings if needed
    }
}
