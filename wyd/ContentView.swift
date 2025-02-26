import SwiftUI

// Optional: Hex color initializer for convenience
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
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            Color(red: 243/255, green: 241/255, blue: 234/255)
                .ignoresSafeArea()

            if showOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else {
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
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
