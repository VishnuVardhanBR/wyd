import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r)/255,
                  green: Double(g)/255,
                  blue: Double(b)/255,
                  opacity: Double(a)/255)
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showOnboarding = false
    @State private var showLogin = false

    var body: some View {
        // If user is logged in, show GoalsView
        if let user = authViewModel.user {
            GoalsView(user: user)
        } else {
            // Otherwise, show splash screen
            ZStack {
                Color(hex: "#F3F1EA")
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("wyd?")
                        .font(.custom("EBGaramond-Italic", size: 100))
                        .foregroundColor(.black)
                        .padding()

                    Button(action: {
                        withAnimation {
                            showOnboarding = true
                        }
                    }) {
                        HStack {
                            Text("Help me out")
                                .font(.custom("EBGaramond-Italic", size: 24))
                                .foregroundColor(.white)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 40)
                        .background(Color.black)
                        .cornerRadius(10)
                    }

                    // Already have an account?
                    Button(action: {
                        showLogin = true
                    }) {
                        Text("Already have an account?")
                            .font(.custom("EBGaramond-Italic", size: 16))
                            .foregroundColor(.black)
                            .underline()
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            // Present Onboarding or Login as full-screen covers
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView()
                    .environmentObject(authViewModel)
            }
            .fullScreenCover(isPresented: $showLogin) {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
