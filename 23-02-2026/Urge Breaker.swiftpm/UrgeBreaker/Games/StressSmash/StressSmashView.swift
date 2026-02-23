import SwiftUI

struct StressSmashView: View {
    @StateObject var viewModel: StressSmashViewModel
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            // Background particles or shards when smashing
            ShardView(shards: viewModel.shards)
            
            VStack {
                Spacer().frame(height: 80)
                
                // Score and Timer
                HStack {
                    VStack(alignment: .leading) {
                        Text("SMASHES")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.score)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.ubPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("TIME")
                            .font(Theme.fontCaption)
                            .foregroundColor(.secondary)
                        Text("\(Int(viewModel.timeRemaining))s")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(viewModel.timeRemaining < 5 ? .ubDanger : .ubPrimary)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Main Interaction Area
                ZStack {
                    // Target Object
                    Button(action: {
                        viewModel.smash()
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.ubPrimary, .ubPrimary.opacity(0.7)],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .scaleEffect(viewModel.buttonScale)
                                .shadow(color: Color.ubPrimary.opacity(0.4), radius: 20, x: 0, y: 10)
                            
                            Image(systemName: "hammer.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(viewModel.isSmashing ? -45 : 0))
                        }
                    }
                }
                
                Spacer()
                
                Text("Smash the stress away!")
                    .font(Theme.fontHeadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.startGame()
        }
    }
}

// Simple shard representation
struct ShardView: View {
    let shards: [StressSmashShard]
    
    var body: some View {
        ZStack {
            ForEach(shards) { shard in
                Image(systemName: shard.icon)
                    .font(.system(size: shard.size))
                    .foregroundColor(shard.color.opacity(shard.opacity))
                    .position(shard.position)
            }
        }
    }
}

struct StressSmashShard: Identifiable {
    let id = UUID()
    var position: CGPoint
    var icon: String
    var size: CGFloat
    var color: Color
    var opacity: Double
}
