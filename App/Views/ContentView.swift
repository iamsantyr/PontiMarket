import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var languageManager: LanguageManager

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var selectedOption: String = "Log In"
    @State private var isMarketVisible: Bool = false
    @State private var showPasswordRecovery = false
    @State private var recoveryEmail: String = ""
    @State private var showWelcomeMessage: Bool = false
    @State private var selectedTab: Int = 0
    @State private var initialized = false

    @Environment(\.colorScheme) var colorScheme

    private func getTranslation(for key: String) -> String {
        return Languages.shared.getTranslation(for: key, language: languageManager.selectedLanguage)
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(1), Color.black.opacity(0.7)]),
                           startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if !authManager.isLoggedIn {
                    HStack {
                        LanguageSelectorView(selectedLanguage: $languageManager.selectedLanguage)
                    }
                }

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
                } else {
                    Spacer()

                    VStack {
                        Picker(getTranslation(for: LocalizationKeys.selectOption), selection: $selectedOption) {
                            Text(getTranslation(for: LocalizationKeys.logIn)).tag("Log In")
                            Text(getTranslation(for: LocalizationKeys.signUp)).tag("Sign Up")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 50)
                        .padding(.bottom)

                        if selectedOption == "Log In" {
                            LoginFormView(
                                email: $email,
                                password: $password,
                                isPasswordVisible: $isPasswordVisible,
                                errorMessage: $authManager.errorMessage,
                                onLogin: {
                                    authManager.login(email: email, password: password)

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
                                },
                                selectedLanguage: languageManager.selectedLanguage
                            )
                        } else {
                            SignUpFormView(
                                name: $name,
                                email: $email,
                                password: $password,
                                confirmPassword: $confirmPassword,
                                selectedLanguage: languageManager.selectedLanguage
                            )
                        }

                        if selectedOption == "Log In" {
                            Button(action: {
                                showPasswordRecovery = true
                            }) {
                                Text(getTranslation(for: LocalizationKeys.forgotPassword))
                                    .foregroundColor(.white)
                                    .underline()
                                    .padding(.top, 10)
                            }
                            .padding(.bottom)
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

            if showPasswordRecovery {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .onTapGesture {
                        showPasswordRecovery = false
                    }

                PasswordRecoveryPopup(
                    recoveryEmail: $recoveryEmail,
                    language: languageManager.selectedLanguage,
                    showPopup: $showPasswordRecovery
                )
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            // Si la sesión ya estaba activa al lanzar la app, mostrar directamente el marketplace
            if authManager.isLoggedIn && !initialized {
                initialized = true
                isMarketVisible = true
            }
        }
        .animation(.easeInOut, value: showPasswordRecovery)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManager())
            .environmentObject(LanguageManager())
    }
}
