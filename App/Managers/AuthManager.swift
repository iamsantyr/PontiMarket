import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthManager: ObservableObject {
static let shared = AuthManager() // Singleton

@Published var isLoggedIn: Bool = false
@Published var errorMessage: String = ""
@Published var showVerificationAlert: Bool = false
@Published var verificationMessage: String = ""

@AppStorage("selectedLanguage") var selectedLanguage: String = "English"
@AppStorage("rememberMe") var rememberMe: Bool = false

public init() {
if let user = Auth.auth().currentUser, rememberMe {
self.isLoggedIn = true
print("✅ Sesión restaurada para: \(user.email ?? "(sin email)")")
} else {
self.isLoggedIn = false
}
}

private func isValidEmail(_ email: String) -> Bool {
let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
}

private func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
FirestoreManager.shared.doesEmailExist(normalizedEmail, completion: completion)
}

func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
guard isValidEmail(email) else {
completion(false, "El formato del correo electrónico no es válido.")
return
}

Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
DispatchQueue.main.async {
if let error = error {
self?.errorMessage = error.localizedDescription
completion(false, error.localizedDescription)
} else if let user = authResult?.user {
if user.isEmailVerified {
self?.isLoggedIn = true
self?.saveUserSessionIfNeeded()
completion(true, nil)
} else {
let message = "Tu correo no está verificado. Por favor, revisa tu bandeja de entrada."
self?.errorMessage = message
self?.verificationMessage = message
self?.showVerificationAlert = true
try? Auth.auth().signOut()
completion(false, message)
}
} else {
completion(false, "Error desconocido.")
}
}
}
}

func register(email: String, password: String, name: String = "Usuario", completion: @escaping (Bool, String?) -> Void) {
Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
DispatchQueue.main.async {
if let error = error {
completion(false, error.localizedDescription)
} else if let user = authResult?.user {
// Enviar correo de verificación
user.sendEmailVerification { error in
if let error = error {
print("❌ Error al enviar correo de verificación: \(error.localizedDescription)")
let message = "Registro exitoso, pero no se pudo enviar el correo de verificación."
self?.verificationMessage = message
self?.showVerificationAlert = true
completion(false, message)
} else {
print("✅ Correo de verificación enviado a \(email)")
let message = "Registro exitoso. Revisa tu correo y verifica tu cuenta antes de iniciar sesión."
self?.verificationMessage = message
self?.showVerificationAlert = true

// Guardar usuario en Firestore con FirestoreManager
let userModel = UserModel(
id: user.uid,
name: name,
email: email,
profilePictureURL: nil
)

FirestoreManager.shared.saveUser(userModel) { result in
switch result {
case .success:
print("✅ Usuario guardado en Firestore.")
case .failure(let error):
print("❌ Error al guardar en Firestore: \(error.localizedDescription)")
}
}

completion(true, nil)
}
}
}
}
}
}

func sendPasswordReset(email: String, completion: @escaping (Bool, String?) -> Void) {
guard isValidEmail(email) else {
completion(false, "El formato del correo electrónico no es válido.")
return
}

let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

checkIfEmailExists(normalizedEmail) { exists in
DispatchQueue.main.async {
if exists {
Auth.auth().sendPasswordReset(withEmail: normalizedEmail) { error in
if let error = error {
completion(false, "Error al enviar correo de recuperación: \(error.localizedDescription)")
} else {
completion(true, nil)
}
}
} else {
completion(false, "Este correo no está registrado.")
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
print("❌ Error al cerrar sesión: \(signOutError.localizedDescription)")
}
}

func setRememberMe(_ value: Bool) {
rememberMe = value
}

private func saveUserSessionIfNeeded() {
if rememberMe {
DispatchQueue.main.async {
self.isLoggedIn = true
}
}
}
}
