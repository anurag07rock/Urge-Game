import SwiftUI

struct TriggerChip: View {
    let trigger: Trigger
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: trigger.icon)
                    .font(.title3)
                Text(trigger.displayName)
                    .font(Theme.fontCaption)
                    .fontWeight(.medium)
            }
            .frame(width: 85, height: 75)
            .background(isSelected ? Color.ubPrimary : Color.ubSurface)
            .foregroundColor(isSelected ? .white : .ubTextPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.ubPrimary : Color.secondary.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.ubPrimary.opacity(0.2) : Color.clear, radius: 4, x: 0, y: 2)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}
