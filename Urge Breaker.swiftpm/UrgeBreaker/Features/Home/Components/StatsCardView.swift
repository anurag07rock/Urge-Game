import SwiftUI

struct StatsCardView: View {
    let title: String
    let value: Int
    let icon: String // SF Symbol
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    if #available(iOS 17.0, *) {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                            .symbolEffect(.bounce.byLayer, value: value)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    }
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if #available(iOS 17.0, *) {
                    Text("\(value)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.ubTextPrimary)
                        .contentTransition(.numericText(value: Double(value)))
                        .animation(.snappy, value: value)
                } else {
                    Text("\(value)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.ubTextPrimary)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.ubCardBackground)
        .cornerRadius(Theme.layoutRadius)
        .shadow(color: Theme.Shadows.card, radius: 8, x: 0, y: 4)
    }
}
