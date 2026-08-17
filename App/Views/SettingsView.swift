import SwiftUI

struct SettingsView: View {

// MARK: - Propiedades
@AppStorage("selectedLanguage") private var selectedLanguage: String = "English"
@EnvironmentObject var authManager: AuthManager

private let availableLanguages = ["English", "Spanish", "Portuguese", "French"]

// MARK: - Body
var body: some View {
NavigationView {
Form {
// MARK: - Idioma
Section(header: Text(getTranslation(for: "language"))) {
Picker(getTranslation(for: LocalizationKeys.selectLanguage), selection: $selectedLanguage) {
ForEach(availableLanguages, id: \.self) { language in
Text(language).tag(language)
}
}
.pickerStyle(MenuPickerStyle())
}

// MARK: - Cerrar sesión
Section {
Button(action: {
authManager.signOut()
}) {
HStack {
Image(systemName: "rectangle.portrait.and.arrow.right")
Text(getTranslation(for: "signOut"))
}
.foregroundColor(.red)
}
}
}
.navigationTitle(Text(getTranslation(for: "settings")))
}
}

// MARK: - Traducción
private func getTranslation(for key: String) -> String {
return Languages.shared.getTranslation(for: key, language: selectedLanguage)
}
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
static var previews: some View {
SettingsView()
.environmentObject(AuthManager())
}
}
