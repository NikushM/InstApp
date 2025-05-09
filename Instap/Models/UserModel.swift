
import Foundation


struct UserModel: Identifiable {
    let id: String
    let email: String
    let username: String
    let profileImageUrl: String?

    init(id: String, email: String, username: String, profileImageUrl: String?) {
        self.id = id
        self.email = email
        self.username = username
        self.profileImageUrl = profileImageUrl
    }
}

/// Модель посту
struct PostModel: Identifiable {
    let id: String
    let userId: String
    let imageUrl: String
    let caption: String
    let createdAt: Date
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.userId = data["userId"] as? String ?? "Unknown User"
        self.imageUrl = data["imageUrl"] as? String ?? ""
        self.caption = data["caption"] as? String ?? ""
        
        if let timestamp = data["createdAt"] as? TimeInterval {
            self.createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            self.createdAt = Date()
        }
    }
}
