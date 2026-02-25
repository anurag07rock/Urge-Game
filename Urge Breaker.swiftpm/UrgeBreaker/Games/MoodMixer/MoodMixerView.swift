import SwiftUI

struct MoodMixerView: View {
    @StateObject var viewModel: MoodMixerViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.1, blue: 0.25), Color(red: 0.25, green: 0.15, blue: 0.35)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
            
            VStack {
                Spacer().frame(height: 80)
                Text("Mood Mixer").font(Theme.fontTitle).foregroundColor(.white)
                Text("Drag emotions together to blend").font(Theme.fontCaption).foregroundColor(.white.opacity(0.6))
                Spacer()
            }
            
            // Orbs
            ForEach(viewModel.orbs) { orb in
                if !orb.isMerged {
                    ZStack {
                        Circle()
                            .fill(orb.color.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .blur(radius: 15)
                        
                        Circle()
                            .fill(
                                RadialGradient(colors: [orb.color, orb.color.opacity(0.5)],
                                             center: .center, startRadius: 10, endRadius: 45)
                            )
                            .frame(width: 90, height: 90)
                            .shadow(color: orb.color.opacity(0.5), radius: 15)
                        
                        Text(orb.emotion)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .position(orb.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.moveOrb(id: orb.id, to: value.location)
                            }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Signature reveal
            if viewModel.showSignature {
                VStack(spacing: 20) {
                    ZStack {
                        ForEach(viewModel.orbs) { orb in
                            Circle()
                                .fill(orb.color.opacity(0.4))
                                .frame(width: 150, height: 150)
                                .blur(radius: 30)
                        }
                        Circle()
                            .fill(
                                RadialGradient(colors: [.white.opacity(0.3), viewModel.mergedColor.opacity(0.6)],
                                             center: .center, startRadius: 20, endRadius: 80)
                            )
                            .frame(width: 160, height: 160)
                    }
                    
                    Text("Your Emotional Signature")
                        .font(Theme.fontCaption).foregroundColor(.white.opacity(0.6))
                    Text(viewModel.mergedEmotion)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "theatermasks.fill").font(.system(size: 48)).foregroundColor(.purple)
                        Text("Emotions Blended").font(Theme.fontTitle).foregroundColor(.white)
                        Text("You are \(viewModel.mergedEmotion)").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .onAppear { viewModel.startGame() }
    }
}
