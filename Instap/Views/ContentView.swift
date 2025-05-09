import SwiftUI

struct ContentView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage: String? = nil
    @State private var isRegistered = false
    @StateObject private var authViewModel = AuthViewModel.shared
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Кнопка реєстрації
                Button("Sign Up 🚀") {
                    signUp()
                }
                .padding()
                
                // Кнопка входу
                Button("Sign In 🔐") {
                    signIn()
                }
                .padding()
                
                // Відображення помилок
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Login")
            .navigationDestination(isPresented: $isRegistered) {
                SuccessRegistrationView(isLoggedIn: $isLoggedIn)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                ProfileView(isLoggedIn: $isLoggedIn)
            }
        }
    }
    
    // Функція реєстрації
    private func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required!"
            return
        }
        
        AuthManager.shared.signUp(email: email, password: password, username: "") { success, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = error.localizedDescription
                    isRegistered = false
                } else {
                    isRegistered = true
                    errorMessage = nil
                }
            }
        }
    }
    
    // Функція входу
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required!"
            return
        }
        
        AuthManager.shared.signIn(email: email, password: password) { success, error in
            DispatchQueue.main.async {
                if success {
                    isLoggedIn = true
                } else {
                    errorMessage = error?.localizedDescription ?? "Unknown error"
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
