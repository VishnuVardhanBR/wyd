import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            Color(hex: "#F3F1EA")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Welcome Back!")
                    .font(.custom("EBGaramond-Italic", size: 32))
                    .foregroundColor(.black)
                    .padding(.top, 40)

                // Email
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 32)

                // Password
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 32)

                // Sign in button
                Button(action: {
                    authViewModel.signIn(email: email, password: password) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            // On success, close this view
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("Sign In")
                        .font(.custom("EBGaramond-Italic", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)

                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Don't have an account?
                Button(action: {
                    showOnboarding = true
                }) {
                    Text("Don't have an account?")
                        .font(.custom("EBGaramond-Italic", size: 16))
                        .foregroundColor(.black)
                        .underline()
                }
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
                .environmentObject(authViewModel)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
