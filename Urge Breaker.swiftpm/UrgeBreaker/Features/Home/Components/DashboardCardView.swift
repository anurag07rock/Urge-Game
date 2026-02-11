import SwiftUI

struct DashboardCardView: View {
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.ubSecondary.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.ubSecondary)
            }
            
            Text("View Detailed Insights")
                .font(Theme.fontHeadline)
                .foregroundColor(.ubPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.ubSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
