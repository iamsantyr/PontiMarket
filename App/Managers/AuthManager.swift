import Foundation
import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    static let shared = AuthManager() // Singleton

    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "English"
    @AppStorage("rememberMe") var rememberMe: Bool = false

    public init() {
        // Verifica si el usuario está logueado y rememberMe es true
        if let user = Auth.auth().currentUser, rememberMe {
            self.isLoggedIn = true
            print("Sesión restaurada para: \(user.email ?? "(sin email)")")
        } else {
            self.isLoggedIn = false
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isLoggedIn = true
                }
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isLoggedIn = false
            }
        } catch let signOutError {
            print("Error al cerrar sesión: \(signOutError.localizedDescription)")
        }
    }

    func setRememberMe(_ value: Bool) {
        rememberMe = value
    }
}
