import Foundation


class Languages {
    static let shared = Languages()
    
    let translations: [String: [String: String]] = [
        "English": [
            "createAccount": "Create Account",
            "enterEmail": "Enter your email",
            "enterPassword": "Enter your password",
            "confirmPassword": "Confirm your password",
            "logIn": "Log In",
            "signUp": "Sign Up",
            "selectOption": "Select an option",
            "enterName": "Enter your name",
            "forgotPassword": "Forgot your password?",
            "forgotPasswordTitle": "Password Recovery",
            "enterEmailForRecovery": "Enter the email associated with your account",
            "sendEmail": "Send Recovery Email",
            "cancel": "Cancel",
            "invalidCredentials": "Invalid credentials, please try again.",
            "welcome": "Welcome",
            "selectLanguage": "Select Language",
            "allFieldsRequired": "All fields are required",
            "passwordsDoNotMatch": "Passwords do not match"
        ],
        "Spanish": [
            "createAccount": "Crear una cuenta",
            "enterEmail": "Ingresa tu correo",
            "enterPassword": "Ingresa tu contraseña",
            "confirmPassword": "Confirma tu contraseña",
            "logIn": "Iniciar Sesión",
            "signUp": "Registrarse",
            "selectOption": "Selecciona una opción",
            "enterName": "Ingresa tu nombre",
            "forgotPassword": "¿Olvidaste tu contraseña?",
            "forgotPasswordTitle": "Recuperación de Contraseña",
            "enterEmailForRecovery": "Ingresa el correo asociado con tu cuenta",
            "sendEmail": "Enviar correo de recuperación",
            "cancel": "Cancelar",
            "invalidCredentials": "Credenciales inválidas, intenta nuevamente.",
            "welcome": "Bienvenido/a",
            "selectLanguage": "Seleccionar idioma",
            "allFieldsRequired": "Todos los campos son obligatorios",
            "passwordsDoNotMatch": "Las contraseñas no coinciden"
        ],
        "Portuguese": [
            "createAccount": "Criar conta",
            "enterEmail": "Digite seu e-mail",
            "enterPassword": "Digite sua senha",
            "confirmPassword": "Confirme sua senha",
            "logIn": "Entrar",
            "signUp": "Cadastrar-se",
            "selectOption": "Selecione uma opção",
            "enterName": "Digite seu nome",
            "forgotPassword": "Esqueceu sua senha?",
            "forgotPasswordTitle": "Recuperação de Senha",
            "enterEmailForRecovery": "Digite o e-mail associado à sua conta",
            "sendEmail": "Enviar E-mail de Recuperação",
            "cancel": "Cancelar",
            "invalidCredentials": "Credenciais inválidas, tente novamente.",
            "welcome": "Bem-vindo",
            "selectLanguage": "Selecionar idioma",
            "allFieldsRequired": "Todos os campos são obrigatórios",
            "passwordsDoNotMatch": "As senhas não coincidem"
        ],
        "French": [
            "createAccount": "Créer un compte",
            "enterEmail": "Entrez votre e-mail",
            "enterPassword": "Entrez votre mot de passe",
            "confirmPassword": "Confirmez votre mot de passe",
            "logIn": "Connexion",
            "signUp": "S'inscrire",
            "selectOption": "Sélectionnez une option",
            "enterName": "Entrez votre nom",
            "forgotPassword": "Mot de passe oublié ?",
            "forgotPasswordTitle": "Récupération du mot de passe",
            "enterEmailForRecovery": "Entrez l'e-mail associé à votre compte",
            "sendEmail": "Envoyer l'e-mail de récupération",
            "cancel": "Annuler",
            "invalidCredentials": "Identifiants invalides, veuillez réessayer.",
            "welcome": "Bienvenue",
            "selectLanguage": "Sélectionner la langue",
            "allFieldsRequired": "Tous les champs sont obligatoires",
            "passwordsDoNotMatch": "Les mots de passe ne correspondent pas"
        ]
    ]
    
    private init() {}
    
    func getTranslation(for key: String, language: String) -> String {
        return translations[language]?[key] ?? key
    }
}

// Extensión para facilitar el uso de traducciones en Strings
extension String {
    func localized(in language: String) -> String {
        return Languages.shared.getTranslation(for: self, language: language)
    }
}
