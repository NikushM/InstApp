import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    
    static let shared = AuthViewModel() // Singleton
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    func signUp(email: String, password: String, username: String) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.isLoggedIn = true
        }
    }
    
    func signIn(email: String, password: String) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            self.isLoggedIn = true
        }
    }
}

struct User {
    let uid: String
    let email: String
    let username: String
    let profileImageURL: String?
}


