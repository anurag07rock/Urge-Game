import SwiftUI

struct WeeklyGraphView: View {
    let data: [(day: String, count: Int, isToday: Bool)]
    
    var maxCount: Int {
        data.map { $0.count }.max() ?? 1
    }
    
    @State private var animateBars = false
    
    var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Last 7 Days")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.ubTextPrimary)
                    .padding(.leading, 4)
                
                ZStack(alignment: .bottom) {
                    // Background Grid Lines (Optional Polish)
                    VStack {
                        Divider().opacity(0.5)
                        Spacer()
                        Divider().opacity(0.5)
                        Spacer()
                        Divider().opacity(0.5)
                    }
                    .frame(height: 140)
                    
                    HStack(alignment: .bottom, spacing: 12) {
                        ForEach(data, id: \.day) { item in
                            VStack(spacing: 8) {
                                Spacer()
                                
                                // Cylindrical Bar
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
//                                                item.isToday ? Color.ubPrimary.opacity(0.9) : Color.ubPrimary.opacity(0.4),
                                                item.isToday ? Color.ubPrimary : Color.ubPrimary.opacity(0.3),
                                                item.isToday ? Color.ubPrimary.opacity(0.8) : Color.ubPrimary.opacity(0.2)
                                            ]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: animateBars ? barHeight(for: item.count) : 0)
                                    .frame(minHeight: 12) // Minimum capsule height
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(data.firstIndex(where: {$0.day == item.day}) ?? 0) * 0.05), value: animateBars)
                                    // Subtle 3D shadow/depth
                                    .shadow(color: item.isToday ? Color.ubPrimary.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                                
                                // Label
                                Text(item.day)
                                    .font(.system(size: 10, weight: item.isToday ? .bold : .medium, design: .rounded))
                                    .foregroundColor(item.isToday ? .ubPrimary : .secondary)
                                    .accessibilityLabel("\(item.day): \(item.count) urges")
                            }
                        }
                    }
                    .frame(height: 140)
                }
                .padding(Theme.layoutPadding)
                .background(
                    RoundedRectangle(cornerRadius: Theme.layoutRadius)
                        .fill(Color.ubCardBackground)
                        .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 4)
                )
                .onAppear {
                    animateBars = true
                }
            }
    }
    
    private func barHeight(for count: Int) -> CGFloat {
        guard maxCount > 0 else { return 8 }
        let height = CGFloat(count) / CGFloat(maxCount) * 100
        return max(height, 8)
    }
}
