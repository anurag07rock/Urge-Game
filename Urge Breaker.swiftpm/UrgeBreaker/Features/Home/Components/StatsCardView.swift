import SwiftUI

struct StatsCardView: View {
    let title: String
    let value: Int
    let icon: String // SF Symbol
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                if #available(iOS 17.0, *) {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                        .symbolEffect(.bounce.byLayer, value: value)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if #available(iOS 17.0, *) {
                    Text("\(value)")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.ubPrimary)
                        .contentTransition(.numericText(value: Double(value)))
                        .animation(.snappy, value: value)
                } else {
                    Text("\(value)")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.ubPrimary)
                }
                
                Text(title)
                    .font(Theme.fontSubheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.layoutRadius)
                .fill(Color.ubCardBackground)
                .shadow(color: Theme.Shadows.card, radius: 8, x: 0, y: 4)
        )
    }
}
