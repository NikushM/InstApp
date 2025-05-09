import FirebaseAuth
import FirebaseFirestore

final class AuthManager {
    static let shared = AuthManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    /// ✅ Реєстрація нового користувача
    func signUp(email: String, password: String, username: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let user = result?.user, error == nil {
                // Додаємо користувача в Firestore
                self.saveUserToFirestore(uid: user.uid, email: email, username: username) { success, error in
                    if success {
                        Instap.UserDefaultsManager.shared.setUserLoggedIn(true)
                        completion(true, nil)
                    } else {
                        completion(false, error)
                    }
                }
            } else {
                completion(false, error)
            }
        }
    }
    
    /// ✅ Збереження користувача у Firestore
    private func saveUserToFirestore(uid: String, email: String, username: String, completion: @escaping (Bool, Error?) -> Void) {
        let userRef = db.collection("users").document(uid)
        
        let userData: [String: Any] = [
            "uid": uid,
            "email": email,
            "username": username,
            "profileImageUrl": "",
            "createdAt": Timestamp()
        ]
        
        userRef.setData(userData) { error in
            if let error = error {
                print("❌ Error saving user: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("✅ User saved successfully!")
                completion(true, nil)
            }
        }
    }
    
    /// ✅ Отримання даних про поточного користувача
    func fetchUserData(completion: @escaping (UserModel?, Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil, NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user logged in"]))
            return
        }

        let userRef = Firestore.firestore().collection("users").document(uid)
        userRef.getDocument(completion: { document, error in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                let data = document.data() ?? [:]
                let email = data["email"] as? String ?? "Unknown Email"
                let username = data["username"] as? String ?? "Unknown Username"
                let profileImageUrl = data["profileImageUrl"] as? String ?? ""

                let user = UserModel(id: uid, email: email, username: username, profileImageUrl: profileImageUrl)
                completion(user, nil)
            } else {
                completion(nil, NSError(domain: "FirestoreError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
            }
        }
    )}

    
    /// ✅ Вхід користувача
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        print("🟢 Спроба входу за допомогою електронної пошти: \(email)")
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ Помилка входу: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("✅ Вхід виконано успішно")
                Instap.UserDefaultsManager.shared.setUserLoggedIn(true)
                completion(true, nil)
            }
        }
    }
    
    /// ✅ Вихід користувача
    func signOut() {
        do {
            try Auth.auth().signOut()
            Instap.UserDefaultsManager.shared.setUserLoggedIn(false)
            print("✅ Користувач вийшов із системи")
        } catch let error {
            print("❌ Помилка виходу: \(error.localizedDescription)")
        }
    }
    
    /// ✅ Отримання ID поточного користувача
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
