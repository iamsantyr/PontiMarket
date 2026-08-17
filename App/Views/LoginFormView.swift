import SwiftUI
import FirebaseAuth

struct LoginFormView: View {

// MARK: - Observed Object
@ObservedObject var authManager = AuthManager.shared

// MARK: - Props
@Binding var email: String
@Binding var password: String
@Binding var isPasswordVisible: Bool
@Binding var errorMessage: String
var onLogin: () -> Void
var selectedLanguage: String

// MARK: - Estado interno
@State private var isLoading = false
@State private var showAlert = false
@State private var alertTitle = ""
@State private var alertMessage = ""

// MARK: - Cuerpo
var body: some View {
VStack(spacing: 30) {

// Logo
Image(systemName: "person.circle.fill")
.resizable()
.aspectRatio(contentMode: .fit)
.frame(width: 80, height: 80)
.foregroundColor(.white)
.padding(.bottom, 10)

// Bienvenida
Text(getTranslation("welcome"))
.font(.title2)
.fontWeight(.bold)
.foregroundColor(.white)

// Campo de email
HStack {
Image(systemName: "person.fill")
.foregroundColor(.gray)
TextField(getTranslation(LocalizationKeys.enterEmail), text: $email)
.autocapitalization(.none)
.keyboardType(.emailAddress)
.disableAutocorrection(true)
.foregroundColor(.primary)
}
.padding()
.background(Color(UIColor.systemBackground).opacity(0.8))
.cornerRadius(10)

// Campo de contraseña
HStack {
Image(systemName: "lock.fill")
.foregroundColor(.gray)
if isPasswordVisible {
TextField(getTranslation(LocalizationKeys.enterPassword), text: $password)
.disableAutocorrection(true)
.foregroundColor(.primary)
} else {
SecureField(getTranslation(LocalizationKeys.enterPassword), text: $password)
.foregroundColor(.primary)
}
Button(action: {
isPasswordVisible.toggle()
}) {
Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
.foregroundColor(.gray)
}
}
.padding()
.background(Color(UIColor.systemBackground).opacity(0.8))
.cornerRadius(10)

// Recordar sesión
HStack {
Toggle(isOn: Binding(
get: { authManager.rememberMe },
set: { newValue in authManager.setRememberMe(newValue) }
)) {
Text(getTranslation("remember"))
.foregroundColor(.white)
.font(.footnote)
}
Spacer()
}
.padding(.horizontal, 5)

// Error de login
if !errorMessage.isEmpty {
Text(errorMessage)
.foregroundColor(.red)
.font(.footnote)
.padding(8)
.background(Color.white.opacity(0.7))
.cornerRadius(8)
.padding(.horizontal)
}

// Botón de login
Button(action: handleLogin) {
HStack {
if isLoading {
ProgressView()
.progressViewStyle(CircularProgressViewStyle(tint: .white))
.scaleEffect(1.2)
} else {
Image(systemName: "arrow.right.circle.fill")
Text(getTranslation(LocalizationKeys.logIn))
}
}
.frame(width: 200, height: 50)
.background(isLoading ? Color.gray : Color.blue)
.foregroundColor(.white)
.cornerRadius(10)
.shadow(radius: 3)
.animation(.easeInOut(duration: 0.2), value: isLoading)
}
.padding(.top, 10)
.disabled(isLoading)
}
.padding(.horizontal, 30)
.padding(.vertical, 20)
.alert(isPresented: $showAlert) {
Alert(
title: Text(alertTitle),
message: Text(alertMessage),
dismissButton: .default(Text(getTranslation("ok")))
)
}
}

// MARK: - Función de login
private func handleLogin() {
errorMessage = ""

guard isValidEmail(email) else {
errorMessage = getTranslation("invalidEmailFormat")
return
}

isLoading = true

AuthManager.shared.login(email: email, password: password) { success, error in
isLoading = false

if success {
if let user = Auth.auth().currentUser, !user.isEmailVerified {
alertTitle = getTranslation("emailNotVerifiedTitle")
alertMessage = getTranslation("emailNotVerifiedMessage")
showAlert = true
try? Auth.auth().signOut()
} else {
onLogin()
}
} else {
errorMessage = error ?? getTranslation("unknownError")
}
}
}

// MARK: - Validación de correo
private func isValidEmail(_ email: String) -> Bool {
let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
}

// MARK: - Traducción
private func getTranslation(_ key: String) -> String {
Languages.shared.getTranslation(for: key, language: selectedLanguage)
}
}
