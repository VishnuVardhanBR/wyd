import SwiftUI

// MARK: - Onboarding Steps (2-step flow)
enum OnboardingStep: Int, CaseIterable {
    case motivation
    case priority

    var title: String {
        switch self {
        case .motivation: return "Motivation"
        case .priority:   return "Priority"
        }
    }

    static var totalSteps: Int { Self.allCases.count }
}

struct OnboardingView: View {
    @State private var currentStep: OnboardingStep = .motivation
    @State private var showQuestion: Bool = true

    // Shared user inputs
    @State private var motivationAnswer: String = ""
    @State private var priorityText: String = ""

    // Progress from 0..1
    private var progress: CGFloat {
        CGFloat(currentStep.rawValue + 1) / CGFloat(OnboardingStep.totalSteps)
    }

    var body: some View {
        ZStack {
            Color(red: 243/255, green: 241/255, blue: 234/255)
                .ignoresSafeArea()

            VStack {
                // Top Bar (Back / Next)
                HStack {
                    // Back button appears after the first step
                    if currentStep != .motivation {
                        Button(action: goBack) {
                            Text("Back")
                                .font(.custom("EBGaramond-Italic", size: 18))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    // Next button (or "Done") on top right
                    if currentStep != .priority {
                        // Step 1
                        Button(action: goNext) {
                            Text("Next")
                                .font(.custom("EBGaramond-Bold", size: 18)) // Heavier weight
                                .foregroundColor(.black)
                        }
                    } else {
                        // Step 2
                        Button(action: finishOnboarding) {
                            Text("Done")
                                .font(.custom("EBGaramond-Bold", size: 18)) // Heavier weight
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Progress bar & title
                VStack(alignment: .leading, spacing: 8) {
                    Text("Step \(currentStep.rawValue + 1) of \(OnboardingStep.totalSteps): \(currentStep.title)")
                        .font(.custom("EBGaramond-Italic", size: 20))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                    ProgressBar(progress: progress)
                }
                .padding(.top)

                Spacer()

                // Question content
                ZStack {
                    if showQuestion {
                        currentStepView
                            .transition(.opacity)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Current Step View
    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case .motivation:
            MotivationQuestionView(answer: $motivationAnswer)
        case .priority:
            PriorityQuestionView(text: $priorityText)
        }
    }

    // MARK: - Navigation
    private func goNext() {
        // Validate step
        guard validateCurrentStep() else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            showQuestion = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = next
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                showQuestion = true
            }
        }
    }

    private func goBack() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showQuestion = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let prev = OnboardingStep(rawValue: currentStep.rawValue - 1) {
                currentStep = prev
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                showQuestion = true
            }
        }
    }

    private func finishOnboarding() {
        // Validate final step
        guard validateCurrentStep() else { return }

        // For now, just print results (or close onboarding)
        print("Motivation: \(motivationAnswer)")
        print("Priority: \(priorityText)")
        // TODO: Possibly pass these values to your LLM or store them in app state
    }

    // MARK: - Validation
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .motivation:
            return !motivationAnswer.isEmpty
        case .priority:
            return !priorityText.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.3))
                Capsule()
                    .frame(width: geometry.size.width * progress, height: 8)
                    .foregroundColor(Color(hex: "#7a7975"))
                    .animation(.easeInOut, value: progress)
            }
        }
        .frame(height: 8)
        .padding(.horizontal)
    }
}

// MARK: - Question 1: Motivation
struct MotivationQuestionView: View {
    @Binding var answer: String
    private let options = [
        "I’m in the groove",
        "I’m getting started",
        "I need a push"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("How’s your drive right now?")
                .font(.custom("EBGaramond-Italic", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            ForEach(options, id: \.self) { option in
                SelectableCard(text: option, isSelected: answer == option) {
                    answer = option
                }
            }
        }
        .padding()
    }
}

// MARK: - Question 2: Priority
struct PriorityQuestionView: View {
    @Binding var text: String

    var body: some View {
        VStack(spacing: 20) {
            Text("What’s one small change you’d like to see in your life today?")
                .font(.custom("EBGaramond-Italic", size: 24))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextEditor(text: $text)
                .font(.custom("EBGaramond-Regular", size: 18))
                .foregroundColor(.black)
                .padding()
                .frame(height: 150)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1))
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Reusable Selectable Card
struct SelectableCard: View {
    let text: String
    let isSelected: Bool
    var onTap: () -> Void

    // Updated colors
    private let unselectedColor = Color(hex: "#b4b3ae")
    private let selectedColor   = Color(hex: "#7a7975")

    var body: some View {
        Text(text)
            .font(.custom("EBGaramond-Regular", size: 18))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: 300)
            .background(isSelected ? selectedColor : unselectedColor)
            .cornerRadius(12)
            .onTapGesture { onTap() }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
