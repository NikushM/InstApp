import FirebaseStorage
import SwiftUICore
import Foundation
import SwiftUI

final class StorageManager {
    static let shared = StorageManager() // Singleton
    private let storage = Storage.storage().reference() // Ініціалізація Firebase Storage
    
    private init() {}
    
    /// Завантажує фото профілю
    func uploadProfilePicture(uid: String, imageData: Data, completion: @escaping (URL?) -> Void) {
        let ref = storage.child("profile_pictures/\(uid).jpg")
        
        ref.putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }
}
