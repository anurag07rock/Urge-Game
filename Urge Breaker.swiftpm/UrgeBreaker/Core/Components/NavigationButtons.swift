import SwiftUI

struct GameBackButton: View {
    @Environment(\.dismiss) var dismiss
    var onDismiss: (() -> Void)? = nil
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            onDismiss?()
            dismiss()
        }) {
            Circle()
                .fill(Color.ubSurface)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.ubPrimary)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .accessibilityLabel("Go Back")
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct CircularCloseButton: View {
    var action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.ubSurface)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.secondary)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .accessibilityLabel("Close")
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
