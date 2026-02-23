import SwiftUI

struct Grounding54321View: View {
    @StateObject var viewModel: Grounding54321ViewModel
    @Environment(\.dismiss) var dismiss
    
    // To handle transitions
    @Namespace private var animation
    
    init(onComplete: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: Grounding54321ViewModel(onComplete: onComplete))
    }
    
    var body: some View {
        ZStack {
            Color.ubBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header / Progress
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(Circle().fill(Color.ubSurface))
                    }
                    
                    Spacer()
                    
                    Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.steps.count)")
                        .font(Theme.fontSubheadline)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                        .id("step-counter-\(viewModel.currentStepIndex)")
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Content Card
                VStack(spacing: 24) {
                    // Icon
                    if #available(iOS 17.0, *) {
                        Image(systemName: viewModel.steps[viewModel.currentStepIndex].icon)
                            .font(.system(size: 60))
                            .foregroundColor(.ubPrimary)
                            .padding(30)
                            .background(Circle().fill(Color.ubSurface))
                            .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 5)
                            .symbolEffect(.bounce.byLayer, value: viewModel.currentStepIndex)
                            .transition(.scale.combined(with: .opacity))
                            .id("icon-\(viewModel.currentStepIndex)")
                    } else {
                        Image(systemName: viewModel.steps[viewModel.currentStepIndex].icon)
                            .font(.system(size: 60))
                            .foregroundColor(.ubPrimary)
                            .padding(30)
                            .background(Circle().fill(Color.ubSurface))
                            .shadow(color: Theme.Shadows.card, radius: 10, x: 0, y: 5)
                            .transition(.scale.combined(with: .opacity))
                            .id("icon-\(viewModel.currentStepIndex)")
                    }
                    
                    VStack(spacing: 12) {
                        Text(viewModel.steps[viewModel.currentStepIndex].instruction)
                            .font(Theme.fontTitle)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.ubTextPrimary)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .id("title-\(viewModel.currentStepIndex)")
                        
                        Text(viewModel.steps[viewModel.currentStepIndex].title)
                            .font(Theme.fontHeadline)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .transition(.opacity)
                            .id("subtitle-\(viewModel.currentStepIndex)")
                    }
                    
                    // Examples List
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.steps[viewModel.currentStepIndex].examples, id: \.self) { example in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.ubPrimary.opacity(0.6))
                                    .frame(width: 6, height: 6)
                                Text(example)
                                    .font(Theme.fontBody)
                                    .foregroundColor(.ubTextPrimary)
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.ubCardBackground)
                    .cornerRadius(Theme.layoutRadius)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .id("examples-\(viewModel.currentStepIndex)")
                    
                    Text(viewModel.steps[viewModel.currentStepIndex].subtext)
                        .font(Theme.fontCaption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity)
                        .id("subtext-\(viewModel.currentStepIndex)")
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal, Theme.layoutPadding)
                
                // Action Button
                Button(action: {
                    Haptics.playSelection()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.nextStep()
                    }
                }) {
                    Text(viewModel.isLastStep ? "Finish" : "Next")
                        .font(Theme.fontHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.ubPrimary)
                        .cornerRadius(Theme.layoutRadius)
                        .shadow(color: Color.ubPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, Theme.layoutPadding)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.startTimer()
        }
    }
}
