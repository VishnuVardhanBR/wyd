import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var db = Firestore.firestore()
    
    init() {
        // Listen for changes to Firebase Auth
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    deinit {
        // Stop listening
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Sign up new user with email/password
    func signUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
                return
            }
            guard let user = authResult?.user else {
                completion(NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user object"]))
                return
            }
            // Create a user document in Firestore
            self.createUserDocument(user: user) {
                completion(nil)
            }
        }
    }
    
    // Sign in existing user with email/password
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            completion(error)
        }
    }
    
    // Sign out
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // Create user doc in Firestore at /users/{uid}
    private func createUserDocument(user: User, completion: @escaping () -> Void) {
        let docRef = db.collection("users").document(user.uid)
        let data: [String: Any] = [
            "email": user.email ?? "",
            "createdAt": FieldValue.serverTimestamp()
        ]
        docRef.setData(data) { error in
            if let error = error {
                print("Error creating user doc: \(error.localizedDescription)")
            }
            completion()
        }
    }
}
