import SwiftUI
import Combine

struct GroundingStep {
    let title: String
    let instruction: String
    let examples: [String]
    let subtext: String
    let icon: String
}

@MainActor
class Grounding54321ViewModel: ObservableObject {
    @Published var currentStepIndex: Int = 0
    @Published var timeSpent: TimeInterval = 0
    
    private var cancelable: AnyCancellable?
    var onComplete: () -> Void
    
    let steps: [GroundingStep] = [
        GroundingStep(
            title: "5 Things You See",
            instruction: "Look Around",
            examples: ["A chair", "The light on the ceiling", "Your hands", "A window", "The floor", "A plant", "Your phone"],
            subtext: "It can be anything in your environment, big or small.",
            icon: "eye.fill"
        ),
        GroundingStep(
            title: "4 Things You Feel",
            instruction: "Notice Physical Sensations",
            examples: ["Your feet touching the floor", "The chair supporting your body", "Your clothes on your skin", "The temperature of the air", "Your breath moving", "Your hands resting"],
            subtext: "Focus on physical sensations.",
            icon: "hand.raised.fill"
        ),
        GroundingStep(
            title: "3 Things You Hear",
            instruction: "Listen Carefully",
            examples: ["Air conditioning", "Distant traffic", "Birds", "Your breathing", "A clock ticking", "Background voices"],
            subtext: "Even quiet sounds count.",
            icon: "ear"
        ),
        GroundingStep(
            title: "2 Things You Smell",
            instruction: "Notice the Air Around You",
            examples: ["Soap", "Fresh air", "Food nearby", "Coffee", "Perfume", "Your clothes"],
            subtext: "If you can’t smell anything strong, that’s okay. Just notice neutral air.",
            icon: "nose"
        ),
        GroundingStep(
            title: "1 Thing You're Grateful For",
            instruction: "Find One Thing",
            examples: ["A person who cares about you", "Having a safe space", "Your body", "A recent small win", "This moment of calm"],
            subtext: "It can be something very small.",
            icon: "heart.fill"
        )
    ]
    
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    var currentStep: GroundingStep {
        steps[currentStepIndex]
    }
    
    var progress: Double {
        Double(currentStepIndex + 1) / Double(steps.count)
    }
    
    var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }
    
    func nextStep() {
        if isLastStep {
            finish()
        } else {
            withAnimation {
                currentStepIndex += 1
            }
        }
    }
    
    func startTimer() {
        cancelable = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                self?.timeSpent += 1
            }
    }
    
    func stopTimer() {
        cancelable?.cancel()
        cancelable = nil
    }
    
    func finish() {
        stopTimer()
        onComplete()
    }
}
