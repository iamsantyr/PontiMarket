import SwiftUI
import Foundation


class LanguageManager: ObservableObject {
    @AppStorage("selectedLanguage") var selectedLanguage: String = "English"
}
