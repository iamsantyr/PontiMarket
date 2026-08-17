import SwiftUI
import FirebaseCore
import Firebase

// MARK: - Punto de entrada de la app
@main
struct AppApp: App {
@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

// MARK: - StateObjects compartidos globalmente
@StateObject private var languageManager = LanguageManager()
@StateObject private var authManager = AuthManager()

var body: some Scene {
WindowGroup {
ContentView()
.environmentObject(languageManager)
.environmentObject(authManager)
}
}
}

// MARK: - Configuración de Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
func application(_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
FirebaseApp.configure()
return true
}
}
