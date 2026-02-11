import SwiftUI

struct OnboardingPageView: View {
    let title: String
    let description: String
    let icon: String // SF Symbol name
    let color: Color
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundColor(color)
                .padding()
                .background(Circle().fill(Color.ubSurface))
                .shadow(radius: 5)
                .padding(.bottom, 20)
            
            Text(title)
                .font(Theme.fontTitle)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(Theme.fontBody)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
        .padding(.horizontal, 40)
    }
}
