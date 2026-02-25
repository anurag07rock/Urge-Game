import SwiftUI

struct RootAndGrowView: View {
    @StateObject var viewModel: RootAndGrowViewModel
    
    var body: some View {
        ZStack {
            backgroundGradient
            groundLine
            treeContent
            uiOverlay
            completionOverlay
        }
        .contentShape(Rectangle())
        .onTapGesture { viewModel.tap() }
        .onAppear { viewModel.startGame() }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(red: 0.1, green: 0.2, blue: 0.1), Color(red: 0.2, green: 0.35, blue: 0.15)],
            startPoint: .bottom, endPoint: .top
        ).ignoresSafeArea()
    }
    
    private var groundLine: some View {
        Rectangle()
            .fill(Color(red: 0.3, green: 0.2, blue: 0.1))
            .frame(height: 3)
            .offset(y: UIScreen.main.bounds.height * 0.15)
    }
    
    private var treeContent: some View {
        let centerX = UIScreen.main.bounds.width / 2
        let groundY = UIScreen.main.bounds.height * 0.65
        
        return ZStack {
            rootsView(centerX: centerX, groundY: groundY)
            trunkView(centerX: centerX, groundY: groundY)
            branchesView(centerX: centerX, groundY: groundY)
            leafParticlesView
        }
    }
    
    private func rootsView(centerX: CGFloat, groundY: CGFloat) -> some View {
        let rootData = viewModel.roots.enumerated().map { ($0.offset, $0.element) }
        let depth = viewModel.rootDepth
        return ForEach(rootData, id: \.0) { _, root in
            rootLine(centerX: centerX, groundY: groundY, angle: root.angle, length: root.length, depth: depth)
        }
    }
    
    private func rootLine(centerX: CGFloat, groundY: CGFloat, angle: Double, length: CGFloat, depth: CGFloat) -> some View {
        let rad: CGFloat = CGFloat(angle) * .pi / 180
        let endX: CGFloat = centerX + cos(rad) * length * depth * 3
        let endY: CGFloat = groundY + sin(rad) * length * depth * 2
        return Path { path in
            path.move(to: CGPoint(x: centerX, y: groundY))
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        .stroke(Color(red: 0.4, green: 0.25, blue: 0.1), lineWidth: 3)
    }
    
    private func trunkView(centerX: CGFloat, groundY: CGFloat) -> some View {
        let w: CGFloat = 12 + viewModel.treeHeight * 8
        let h: CGFloat = viewModel.treeHeight * 250
        let y: CGFloat = groundY - viewModel.treeHeight * 125
        return Rectangle()
            .fill(
                LinearGradient(colors: [Color(red: 0.35, green: 0.2, blue: 0.1), Color(red: 0.45, green: 0.3, blue: 0.15)],
                             startPoint: .bottom, endPoint: .top)
            )
            .frame(width: w, height: h)
            .position(x: centerX, y: y)
    }
    
    private func branchesView(centerX: CGFloat, groundY: CGFloat) -> some View {
        let branchData = viewModel.branches.enumerated().map { ($0.offset, $0.element) }
        let height = viewModel.treeHeight
        return ForEach(branchData, id: \.0) { i, branch in
            branchItem(centerX: centerX, groundY: groundY, index: i, angle: branch.angle, length: branch.length, treeHeight: height)
        }
    }
    
    private func branchItem(centerX: CGFloat, groundY: CGFloat, index: Int, angle: Double, length: CGFloat, treeHeight: CGFloat) -> some View {
        let branchY: CGFloat = groundY - CGFloat(index + 1) * 25 * treeHeight
        let rad: CGFloat = CGFloat(angle) * .pi / 180
        let endX: CGFloat = centerX + cos(rad) * length * treeHeight * 2
        let endY: CGFloat = branchY + sin(rad) * length * 0.3
        let leafSize: CGFloat = 20 + treeHeight * 15
        
        return ZStack {
            Path { path in
                path.move(to: CGPoint(x: centerX, y: branchY))
                path.addLine(to: CGPoint(x: endX, y: endY))
            }
            .stroke(Color(red: 0.35, green: 0.2, blue: 0.1), lineWidth: 2)
            
            Circle()
                .fill(Color.green.opacity(0.6 + Double(index) * 0.05))
                .frame(width: leafSize, height: leafSize)
                .position(x: endX, y: endY)
                .blur(radius: 3)
        }
    }
    
    private var leafParticlesView: some View {
        ForEach(viewModel.leafParticles, id: \.id) { leaf in
            Image(systemName: "leaf.fill")
                .font(.system(size: 12))
                .foregroundColor(.green.opacity(leaf.opacity))
                .position(x: leaf.x, y: leaf.y)
        }
    }
    
    private var uiOverlay: some View {
        VStack {
            Spacer().frame(height: 80)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GROWTH").font(Theme.fontCaption).foregroundColor(.green.opacity(0.7))
                    Text("\(viewModel.tapCount) / 20")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                Spacer()
            }
            .padding(.horizontal, 30)
            Spacer()
            Text("Tap to grow your tree")
                .font(Theme.fontCaption).foregroundColor(.green.opacity(0.5))
                .padding(.bottom, 40)
        }
    }
    
    private var completionOverlay: some View {
        Group {
            if viewModel.showCompletion {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "tree.fill").font(.system(size: 48)).foregroundColor(.green)
                        Text("Your Tree is Growing!").font(Theme.fontTitle).foregroundColor(.white)
                        Text("Every tap plants roots of resilience.").font(Theme.fontSubheadline).foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
    }
}
