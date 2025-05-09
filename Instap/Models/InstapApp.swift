import SwiftUI

@main
struct InstapApp: App {
    @State private var isUserLoggedIn = UserDefaultsManager.shared.isUserLoggedIn()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if isUserLoggedIn {
                NewsFeedView(isLoggedIn: $isUserLoggedIn)
            } else {
                ContentView()
            }
        }
    }
}
