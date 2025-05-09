import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager() // Singleton
    private let db = Firestore.firestore() // Firestore instance
    
    private init() {}
    
    /// ✅ Збереження користувача після реєстрації
    func saveUserToFirestore(uid: String, email: String, username: String, profileImageURL: String?, completion: @escaping (Bool) -> Void) {
        guard !uid.isEmpty else {
            completion(false)
            return
        }
        
        let userData: [String: Any] = [
            "uid": uid,
            "email": email,
            "username": username,
            "profileImageURL": profileImageURL ?? "",
            "createdAt": Timestamp()
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("❌ Error saving user: \(error.localizedDescription)")
            }
            completion(error == nil)
        }
    }
    
    /// ✅ Отримання інформації про конкретного користувача
    func fetchUser(uid: String, completion: @escaping (UserModel?) -> Void) {
        guard !uid.isEmpty else {
            completion(nil)
            return
        }
        
        db.collection("users").document(uid).getDocument { document, error in
            guard let data = document?.data(), error == nil else {
                print("❌ Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let user = UserModel(
                id: data["uid"] as? String ?? "",
                email: data["email"] as? String ?? "",
                username: data["username"] as? String ?? "",
                profileImageUrl: data["profileImageURL"] as? String ?? ""
            )
            
            completion(user)
        }
    }
    
    /// ✅ Отримання всіх користувачів (наприклад, для стрічки)
    func fetchAllUsers(completion: @escaping ([UserModel]) -> Void) {
        db.collection("users").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Error fetching users: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let users = documents.compactMap { document -> UserModel? in
                let data = document.data()
                return UserModel(
                    id: data["uid"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    profileImageUrl: data["profileImageURL"] as? String ?? ""
                )
            }
            
            completion(users)
        }
    }
}
