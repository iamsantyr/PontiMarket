import SwiftUI

struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "English"
    @EnvironmentObject var authManager: AuthManager

    let availableLanguages = ["English", "Spanish", "Portuguese", "French"]

    var body: some View {
        NavigationView {
            Form {

                Picker(LocalizationKeys.selectLanguage.localized(in: selectedLanguage), selection: $selectedLanguage) {
                    ForEach(availableLanguages, id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                
                
                
                
                Section {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
