import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            Color(hex: "#F3F1EA")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Title
                Text("Do your best work with Wyd")
                    .font(.custom("EBGaramond-Italic", size: 32))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)

                // Subheading
                Text("Enter your email and password to get started")
                    .font(.custom("EBGaramond-Italic", size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // Email
                TextField("name@yourcompany.com", text: $email)
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

                // Sign Up button
                Button(action: {
                    authViewModel.signUp(email: email, password: password) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        } else {
                            // On success, close the register screen
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("Continue with Email")
                        .font(.custom("EBGaramond-Italic", size: 18))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 32)

                // Error
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Disclaimer
                Text("By continuing, you agree to Wyd’s Terms of Service and Privacy Policy.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
