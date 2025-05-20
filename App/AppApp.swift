import SwiftUI
import FirebaseCore
import Firebase

@main
struct AppApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var authManager = AuthManager()
    
    

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(languageManager)
                .environmentObject(authManager)
        }
    }
}
