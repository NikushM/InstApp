import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let isUserLoggedInKey = "isUserLoggedIn"
    
    private init() {}
    
    func setUserLoggedIn(_ isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: isUserLoggedInKey)
    }
    
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: isUserLoggedInKey)
    }
}

