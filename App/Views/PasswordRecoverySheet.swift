import SwiftUI
import FirebaseAuth

struct PasswordRecoverySheet: View {

// MARK: - Parámetros
var language: String
var initialEmail: String

// MARK: - Entorno
@Environment(\.dismiss) var dismiss

// MARK: - Estado
@State private var recoveryEmail: String = ""
@State private var isLoading: Bool = false
@State private var errorMessage: String = ""
@State private var emailSent: Bool = false

// MARK: - Cuerpo
var body: some View {
VStack(spacing: 20) {
// Título
Text(emailSent ? getTranslation("emailSent") :
getTranslation(LocalizationKeys.forgotPasswordTitle))
.font(.title)
.bold()
.multilineTextAlignment(.center)

if emailSent {
// Mensaje después de enviar el correo
Text(getTranslation("recoveryEmailSent"))
.multilineTextAlignment(.center)
.padding(.horizontal)
.foregroundColor(.secondary)

Button(action: {
dismiss()
}) {
Text(getTranslation("done"))
.frame(width: 200, height: 50)
.background(Color.green)
.foregroundColor(.white)
.cornerRadius(10)
}
} else {
// Formulario de recuperación
Text(getTranslation(LocalizationKeys.enterEmailForRecovery))
.multilineTextAlignment(.center)
.padding(.horizontal)

TextField(getTranslation(LocalizationKeys.enterEmail), text: $recoveryEmail)
.textFieldStyle(RoundedBorderTextFieldStyle())
.padding(.horizontal)
.autocapitalization(.none)
.keyboardType(.emailAddress)

if !errorMessage.isEmpty {
Text(errorMessage)
.foregroundColor(.red)
.font(.caption)
.multilineTextAlignment(.center)
.padding(.horizontal)
}

// Botón de enviar
Button(action: sendRecoveryEmail) {
HStack {
if isLoading {
ProgressView()
.progressViewStyle(CircularProgressViewStyle(tint: .white))
} else {
Image(systemName: "paperplane.fill")
Text(getTranslation(LocalizationKeys.sendEmail))
}
}
.frame(width: 200, height: 50)
.background(isValidEmail && !isLoading ? Color.blue : Color.gray)
.foregroundColor(.white)
.cornerRadius(10)
}
.disabled(!isValidEmail || isLoading)

// Botón de cancelar
Button(action: {
dismiss()
}) {
Text(getTranslation(LocalizationKeys.cancel))
.foregroundColor(.red)
}
}
}
.padding()
.frame(maxWidth: 300)
.background(Color(.secondarySystemBackground))
.cornerRadius(20)
.shadow(radius: 10)
.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
.onAppear {
recoveryEmail = initialEmail
}
}

// MARK: - Traducción
private func getTranslation(_ key: String) -> String {
return Languages.shared.getTranslation(for: key, language: language)
}

// MARK: - Validación de email
private var isValidEmail: Bool {
let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
return emailPred.evaluate(with: recoveryEmail)
}

// MARK: - Enviar email de recuperación
private func sendRecoveryEmail() {
isLoading = true
errorMessage = ""

FirestoreManager.shared.doesEmailExist(recoveryEmail) { exists in
DispatchQueue.main.async {
if !exists {
self.errorMessage = getTranslation("emailNotFound")
self.isLoading = false
return
}

Auth.auth().sendPasswordReset(withEmail: recoveryEmail) { error in
DispatchQueue.main.async {
self.isLoading = false
if let error = error {
print("⚠️ Error al enviar correo: \(error.localizedDescription)")
self.errorMessage = getTranslation("errorSendingEmail")
} else {
self.emailSent = true
}
}
}
}
}
}
}

// MARK: - Preview
struct PasswordRecoverySheet_Previews: PreviewProvider {
static var previews: some View {
PasswordRecoverySheet(language: "English", initialEmail: "test@example.com")
}
}
