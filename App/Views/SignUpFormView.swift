import SwiftUI
import FirebaseAuth

struct SignUpFormView: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    @Binding var confirmPassword: String
    @State private var errorMessage: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    var selectedLanguage: String

    private func getTranslation(for key: String) -> String {
        return Languages.shared.getTranslation(for: key, language: selectedLanguage)
    }

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

            // Nombre
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
                TextField(getTranslation(for: LocalizationKeys.enterName), text: $name)
                    .autocapitalization(.words)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)

            // Email
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                TextField(getTranslation(for: LocalizationKeys.enterEmail), text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)

            // Contraseña
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                
                if isPasswordVisible {
                    TextField(getTranslation(for: LocalizationKeys.enterPassword), text: $password)
                } else {
                    SecureField(getTranslation(for: LocalizationKeys.enterPassword), text: $password)
                }
                
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)

            // Confirmar contraseña
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.gray)
                
                if isConfirmPasswordVisible {
                    TextField(getTranslation(for: LocalizationKeys.confirmPassword), text: $confirmPassword)
                } else {
                    SecureField(getTranslation(for: LocalizationKeys.confirmPassword), text: $confirmPassword)
                }
                
                Button(action: {
                    isConfirmPasswordVisible.toggle()
                }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)

            // Mensaje de error
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(5)
            }

            // Botón de registro
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
    }

    private func validateAndRegister() {
        // Reset error message
        errorMessage = ""
        
        // Basic validation
        if name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = getTranslation(for: "allFieldsRequired")
            return
        }
        
        // Email validation
        if !isValidEmail(email) {
            errorMessage = getTranslation(for: "invalidEmail")
            return
        }
        
        // Password length validation
        if password.count < 6 {
            errorMessage = getTranslation(for: "passwordTooShort")
            return
        }

        // Password match validation
        if password != confirmPassword {
            errorMessage = getTranslation(for: "passwordsDoNotMatch")
            return
        }

        // Firebase registration
        AuthManager.shared.register(email: email, password: password) { success, error in
            if success {
                print("Successfully registered: \(name), \(email)")
            } else {
                errorMessage = error ?? getTranslation(for: "unknownError")
            }
        }
    }
    
    // Email validation helper
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview
/*struct SignUpFormView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpFormView(
            name: .constant(""),
            email: .constant(""),
            password: .constant(""),
            confirmPassword: .constant(""),
            selectedLanguage: "English"
        )
    }
}
*/
