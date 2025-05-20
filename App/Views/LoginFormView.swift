import SwiftUI
import FirebaseAuth

struct LoginFormView: View {

    @StateObject var languageManager = LanguageManager()
    @ObservedObject var authManager = AuthManager.shared

    @Binding var email: String
    @Binding var password: String
    @Binding var isPasswordVisible: Bool
    @Binding var errorMessage: String
    var onLogin: () -> Void
    var selectedLanguage: String

    private func getTranslation(for key: String) -> String {
        return Languages.shared.getTranslation(for: key, language: languageManager.selectedLanguage)
    }

    var body: some View {
        VStack(spacing: 30) {

            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
                .padding(.bottom, 10)

            Text(getTranslation(for: "welcome"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Campo de usuario
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.gray)
                TextField(getTranslation(for: LocalizationKeys.enterEmail), text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)

            // Campo de contraseña con icono de ojo
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

            // Toggle para recordar sesión
            HStack {
                Toggle(isOn: Binding(
                    get: { authManager.rememberMe },
                    set: { newValue in
                        authManager.setRememberMe(newValue)
                    }
                )) {
                    Text(getTranslation(for: "remember"))
                        .foregroundColor(.white)
                        .font(.footnote)
                }
                Spacer()
            }
            .padding(.horizontal, 5)

            // Mensaje de error si existe
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(5)
                    .padding(.horizontal)
            }

            // Botón de inicio de sesión
            Button(action: onLogin) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text(getTranslation(for: LocalizationKeys.logIn))
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
}

struct LoginFormView_Previews: PreviewProvider {
    static var previews: some View {
        LoginFormView(
            email: .constant(""),
            password: .constant(""),
            isPasswordVisible: .constant(false),
            errorMessage: .constant(""),
            onLogin: {},
            selectedLanguage: "English"
        )
    }
}
