import SwiftUI
import Firebase

struct ContentView: View {

// MARK: - Entorno
@EnvironmentObject var authManager: AuthManager
@EnvironmentObject var languageManager: LanguageManager
@Environment(\.colorScheme) var colorScheme

// MARK: - Estados
@State private var name: String = ""
@State private var email: String = ""
@State private var password: String = ""
@State private var confirmPassword: String = ""
@State private var isPasswordVisible: Bool = false
@State private var selectedOption: String = "Log In"
@State private var isMarketVisible: Bool = false
@State private var showPasswordRecovery = false
@State private var showWelcomeMessage: Bool = false
@State private var selectedTab: Int = 0
@State private var initialized = false

// MARK: - Traducción
private func getTranslation(for key: String) -> String {
return Languages.shared.getTranslation(for: key, language: languageManager.selectedLanguage)
}

// MARK: - Vista Principal
var body: some View {
ZStack {
LinearGradient(
gradient: Gradient(colors: [Color.white.opacity(1), Color.black.opacity(0.7)]),
startPoint: .top,
endPoint: .bottom
)
.edgesIgnoringSafeArea(.all)

VStack {
// Selector de idioma
if !authManager.isLoggedIn {
HStack {
LanguageSelectorView(selectedLanguage: $languageManager.selectedLanguage)
}
}

// Usuario autenticado
if authManager.isLoggedIn {
if showWelcomeMessage {
Text(getTranslation(for: LocalizationKeys.welcome))
.font(.system(size: 32, weight: .bold, design: .serif))
.italic()
.foregroundColor(.white)
.padding()
.shadow(radius: 2)
.transition(.opacity)
}

if isMarketVisible {
TabView(selection: $selectedTab) {
MarketView()
.tabItem {
Label("Marketplace", systemImage: "cart")
}
.tag(0)

SettingsView()
.tabItem {
Label("Configuraciones", systemImage: "gearshape")
}
.tag(1)
}
.environmentObject(authManager)
.environmentObject(languageManager)
.transition(.opacity)
}

// Usuario NO autenticado
} else {
Spacer()

VStack {
// Selector Login/Registro
Picker(getTranslation(for: LocalizationKeys.selectOption), selection: $selectedOption) {
Text(getTranslation(for: LocalizationKeys.logIn)).tag("Log In")
Text(getTranslation(for: LocalizationKeys.signUp)).tag("Sign Up")
}
.pickerStyle(SegmentedPickerStyle())
.padding(.horizontal, 50)
.padding(.bottom)

// Formulario de login
if selectedOption == "Log In" {
LoginFormView(
email: $email,
password: $password,
isPasswordVisible: $isPasswordVisible,
errorMessage: $authManager.errorMessage,
onLogin: {
authManager.login(email: email, password: password) { success, _ in
if success {
withAnimation {
showWelcomeMessage = true
}

DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
withAnimation {
showWelcomeMessage = false
}
DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
withAnimation {
isMarketVisible = true
}
}
}
}
}
},
selectedLanguage: languageManager.selectedLanguage
)

// Enlace "¿Olvidaste tu contraseña?"
Button(action: {
showPasswordRecovery = true
}) {
Text(getTranslation(for: LocalizationKeys.forgotPassword))
.font(.footnote)
.foregroundColor(.white)
.underline()
.padding(.top, 10)
}

// Formulario de registro
} else {
SignUpFormView(
name: $name,
email: $email,
password: $password,
confirmPassword: $confirmPassword,
selectedLanguage: languageManager.selectedLanguage,
selectedOption: $selectedOption
)
}
}
.padding()
.background(Color.black.opacity(0.15))
.cornerRadius(20)
.shadow(radius: 5)
.padding(.horizontal, 20)

Spacer()
}
}
.animation(.easeInOut, value: selectedOption)
.animation(.easeInOut, value: authManager.isLoggedIn)
}
// MARK: - Ventana de recuperación de contraseña
.sheet(isPresented: $showPasswordRecovery) {
PasswordRecoverySheet(
language: languageManager.selectedLanguage,
initialEmail: email
)
}
// MARK: - Acciones al aparecer
.onAppear {
if authManager.isLoggedIn && !initialized {
initialized = true
isMarketVisible = true
}
}
}
}
