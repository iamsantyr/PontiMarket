import SwiftUI
import Foundation

struct LanguageSelectorView: View {

// MARK: - Binding
@Binding var selectedLanguage: String

// MARK: - Available Languages
private let availableLanguages = ["English", "Spanish", "Portuguese", "French"]

// MARK: - View
var body: some View {
Menu {
// Opciones de idioma
ForEach(availableLanguages, id: \.self) { lang in
Button(action: {
selectedLanguage = lang
}) {
Label(
title: { Text(lang) },
icon: {
if selectedLanguage == lang {
Image(systemName: "checkmark")
.foregroundColor(.blue)
}
}
)
}
}
} label: {
VStack(spacing: 4) {
Image(systemName: "globe")
.foregroundColor(.white)
.padding(10)
.background(Color.black.opacity(0.6))
.clipShape(Circle())

Text("Select Language")
.foregroundColor(.black)
.font(.caption2)
}
}
.padding(.top, 10)
}
}

// MARK: - Preview
/*
struct LanguageSelectorView_Previews: PreviewProvider {
@State static var language = "English"
static var previews: some View {
LanguageSelectorView(selectedLanguage: $language)
}
}
*/
