import SwiftUI
import Foundation

class LanguageManager: ObservableObject {
// MARK: - Persistencia del idioma seleccionado
@AppStorage("selectedLanguage") var selectedLanguage: String = "English" {
didSet {
currentLanguage = selectedLanguage
}
}

// MARK: - Lenguaje actual (reactivo)
@Published var currentLanguage: String = "English"

// MARK: - Inicializador
init() {
currentLanguage = selectedLanguage
}

// MARK: - Cambiar idioma desde el código
func setLanguage(_ language: String) {
selectedLanguage = language
}
}
