import SwiftUI

extension Color {
    // Brand Colors - Calm but Modern
    static let ubPrimary = Color(red: 0.25, green: 0.5, blue: 0.95) // Vibrant yet calm blue
    static let ubSecondary = Color(red: 0.2, green: 0.75, blue: 0.8) // Refreshing teal
    static let ubAccent = Color(red: 1.0, green: 0.65, blue: 0.3) // Warm confident orange
    static let ubSuccess = Color(red: 0.25, green: 0.85, blue: 0.5) // Soft green
    static let ubDanger = Color(red: 1.0, green: 0.4, blue: 0.4) // Soft red
    
    // Semantic Colors
    static let ubBackground: Color = {
        #if os(iOS)
        return Color(UIColor.systemGroupedBackground) // Slightly off-white for better contrast
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }()
    
    static let ubSurface: Color = {
        #if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground) // White cards on grouped background
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }()
    
    static let ubCardBackground: Color = ubSurface
    static let ubSubtleBackground = ubPrimary.opacity(0.1)
    
    static let ubTextPrimary = Color.primary
    static let ubTextSecondary = Color.secondary
}
