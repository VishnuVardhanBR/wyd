import SwiftUI

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
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var currentStep: OnboardingStep = .motivation
    @State private var showQuestion: Bool = true

    @State private var motivationAnswer: String = ""
    @State private var priorityText: String = ""

    @State private var showRegister = false

    private var progress: CGFloat {
        CGFloat(currentStep.rawValue + 1) / CGFloat(OnboardingStep.totalSteps)
    }

    var body: some View {
        ZStack {
            Color(hex: "#F3F1EA")
                .ignoresSafeArea()

            VStack {
                // Top Bar
                HStack {
                    // Back button on second step
                    if currentStep != .motivation {
                        Button(action: goBack) {
                            Text("Back")
                                .font(.custom("EBGaramond-Italic", size: 18))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                    // Next or Done
                    if currentStep != .priority {
                        Button(action: goNext) {
                            Text("Next")
                                .font(.custom("EBGaramond-Bold", size: 18))
                                .foregroundColor(.black)
                        }
                    } else {
                        Button(action: finishOnboarding) {
                            Text("Done")
                                .font(.custom("EBGaramond-Bold", size: 18))
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
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
                .environmentObject(authViewModel)
        }
    }

    // Step View
    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case .motivation:
            MotivationQuestionView(answer: $motivationAnswer)
        case .priority:
            PriorityQuestionView(text: $priorityText)
        }
    }

    // Navigation
    private func goNext() {
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
        guard validateCurrentStep() else { return }
        print("Motivation: \(motivationAnswer)")
        print("Priority: \(priorityText)")
        showRegister = true
    }

    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .motivation:
            return !motivationAnswer.isEmpty
        case .priority:
            return !priorityText.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
}

// Progress Bar
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

// Q1: Motivation
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

// Q2: Priority
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

// Selectable Card
struct SelectableCard: View {
    let text: String
    let isSelected: Bool
    var onTap: () -> Void

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
