import SwiftUI
import FirebaseAuth


struct PasswordRecoverySheet: View {
    @Binding var recoveryEmail: String
    var language: String
    @Environment(\.dismiss) var dismiss // Para cerrar la ventana

    private func getTranslation(for key: String) -> String {
        return Languages.shared.getTranslation(for: key, language: language)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(getTranslation(for: LocalizationKeys.forgotPasswordTitle))
                .font(.title)
                .bold()

            Text(getTranslation(for: LocalizationKeys.enterEmailForRecovery))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            

            TextField(getTranslation(for: LocalizationKeys.enterEmail), text: $recoveryEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            Button(action: {
                dismiss() // Cierra la ventana (aún no implementamos el envío de correo)
            }) {
                Text(getTranslation(for: LocalizationKeys.sendEmail))
                    .frame(width: 200, height: 50)
                    .background(recoveryEmail.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(recoveryEmail.isEmpty)

            Button(action: {
                dismiss() // Cierra la ventana sin hacer nada
            }) {
                Text(getTranslation(for: LocalizationKeys.cancel))
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: 300) // Ajusta el ancho del cuadro de diálogo
        .background(Color(.systemBackground)) // Fondo adaptable al modo oscuro
        .cornerRadius(20)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Centrado en pantalla
    }
}

// Preview
struct PasswordRecoverySheet_Previews: PreviewProvider {
    static var previews: some View {
        PasswordRecoverySheet(recoveryEmail: .constant(""), language: "English")
    }
}
