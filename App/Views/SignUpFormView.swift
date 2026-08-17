import SwiftUI
import FirebaseAuth

struct SignUpFormView: View {

// MARK: - Bindings & Properties
@Binding var name: String
@Binding var email: String
@Binding var password: String
@Binding var confirmPassword: String

var selectedLanguage: String
@Binding var selectedOption: String

@State private var errorMessage: String = ""
@State private var isPasswordVisible: Bool = false
@State private var isConfirmPasswordVisible: Bool = false

@ObservedObject var authManager = AuthManager.shared

// MARK: - Localization Helper
private func getTranslation(for key: String) -> String {
return Languages.shared.getTranslation(for: key, language: selectedLanguage)
}

// MARK: - View
var body: some View {
VStack(spacing: 15) {
Image(systemName: "person.badge.plus")
.resizable()
.aspectRatio(contentMode: .fit)
.frame(width: 80, height: 80)
.foregroundColor(.white)
.padding(.bottom, 10)

Text(getTranslation(for: "createAccount"))
.font(.title2)
.fontWeight(.bold)
.foregroundColor(.white)
.padding(.bottom, 10)

customInputField(
icon: "person.fill",
placeholder: getTranslation(for: LocalizationKeys.enterName),
text: $name,
isSecure: false
)

customInputField(
icon: "envelope.fill",
placeholder: getTranslation(for: LocalizationKeys.enterEmail),
text: $email,
keyboard: .emailAddress,
textInputAutocapitalization: .never,
isSecure: false
)

secureInputField(
icon: "lock.fill",
placeholder: getTranslation(for: LocalizationKeys.enterPassword),
text: $password,
isVisible: $isPasswordVisible
)

secureInputField(
icon: "lock.shield.fill",
placeholder: getTranslation(for: LocalizationKeys.confirmPassword),
text: $confirmPassword,
isVisible: $isConfirmPasswordVisible
)

if !errorMessage.isEmpty {
Text(errorMessage)
.foregroundColor(.red)
.font(.footnote)
.padding(.vertical, 5)
.padding(.horizontal, 10)
.background(Color.white.opacity(0.7))
.cornerRadius(5)
}

Button(action: validateAndRegister) {
HStack {
Image(systemName: "checkmark.circle.fill")
Text(getTranslation(for: LocalizationKeys.signUp))
}
.frame(width: 200, height: 50)
.background(Color.blue)
.foregroundColor(.white)
.cornerRadius(10)
.shadow(radius: 3)
}
.padding(.top, 10)
}
.padding(.horizontal, 30)
.padding(.vertical, 20)
.alert(isPresented: $authManager.showVerificationAlert) {
Alert(
title: Text(getTranslation(for: "verificationSentTitle")),
message: Text(getTranslation(for: "verificationSentMessage")),
dismissButton: .default(Text("OK")) {
selectedOption = "Log In"
name = ""
confirmPassword = ""
}
)
}
}

private func validateAndRegister() {
errorMessage = ""

if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
errorMessage = getTranslation(for: "allFieldsRequired")
return
}

if !isValidEmail(email) {
errorMessage = getTranslation(for: "invalidEmail")
return
}

if password.count < 6 {
errorMessage = getTranslation(for: "passwordTooShort")
return
}

if password != confirmPassword {
errorMessage = getTranslation(for: "passwordsDoNotMatch")
return
}

authManager.register(email: email, password: password, name: name) { success, error in
if success {
print("Successfully registered: \(name), \(email)")
} else {
errorMessage = error ?? getTranslation(for: "unknownError")
}
}
}

private func isValidEmail(_ email: String) -> Bool {
let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
return NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: email)
}

// MARK: - Custom TextFields
@ViewBuilder
private func customInputField(
icon: String,
placeholder: String,
text: Binding<String>,
keyboard: UIKeyboardType = .default,
textInputAutocapitalization: TextInputAutocapitalization = .sentences,
isSecure: Bool = false
) -> some View {
HStack {
Image(systemName: icon)
.foregroundColor(.gray)
TextField(placeholder, text: text)
.keyboardType(keyboard)
.textInputAutocapitalization(textInputAutocapitalization)
.disableAutocorrection(true)
.foregroundColor(.primary)
}
.padding()
.background(Color(UIColor.systemBackground).opacity(0.8))
.cornerRadius(10)
}

@ViewBuilder
private func secureInputField(icon: String, placeholder: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
HStack {
Image(systemName: icon)
.foregroundColor(.gray)
if isVisible.wrappedValue {
TextField(placeholder, text: text)
.disableAutocorrection(true)
.foregroundColor(.primary)
} else {
SecureField(placeholder, text: text)
.foregroundColor(.primary)
}

Button(action: {
isVisible.wrappedValue.toggle()
}) {
Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
.foregroundColor(.gray)
}
}
.padding()
.background(Color(UIColor.systemBackground).opacity(0.8))
.cornerRadius(10)
}
}
