import SwiftUI
import FirebaseAuth

struct PasswordRecoveryPopup: View {
    @Binding var recoveryEmail: String
    var language: String
    @Binding var showPopup: Bool
    
    @State private var popupOffset: CGFloat = 300
    @State private var popupOpacity: Double = 0
    @State private var isLoading: Bool = false
    @State private var emailSent: Bool = false
    @State private var errorMessage: String = ""
    
    private func getTranslation(for key: String) -> String {
        return Languages.shared.getTranslation(for: key, language: language)
    }
    
    private var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: recoveryEmail)
    }

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    closePopup()
                }
            
            // Popup content
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: emailSent ? "checkmark.circle" : "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(emailSent ? .green : .blue)
                        .padding(.top, 20)
                    
                    Text(emailSent
                         ? getTranslation(for: "emailSent")
                         : getTranslation(for: LocalizationKeys.forgotPasswordTitle))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
                
                if emailSent {
                    // Success message
                    Text(getTranslation(for: "recoveryEmailSent"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        closePopup()
                    }) {
                        Text(getTranslation(for: "done"))
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                } else {
                    // Instructions text
                    Text(getTranslation(for: LocalizationKeys.enterEmailForRecovery))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                    
                    // Email field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        
                        TextField(getTranslation(for: LocalizationKeys.enterEmail), text: $recoveryEmail)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding(.vertical, 12)
                        
                        if !recoveryEmail.isEmpty {
                            Button(action: {
                                recoveryEmail = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Error message if any
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Submit button
                    Button(action: sendRecoveryEmail) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text(getTranslation(for: LocalizationKeys.sendEmail))
                            }
                        }
                        .frame(width: 200, height: 50)
                        .background(!isValidEmail || isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    }
                    .disabled(!isValidEmail || isLoading)
                    
                    // Cancel button
                    Button(action: {
                        closePopup()
                    }) {
                        Text(getTranslation(for: LocalizationKeys.cancel))
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                }
            }
            .padding(.vertical, 20)
            .frame(width: 320)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 15)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .offset(y: popupOffset)
            .opacity(popupOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    popupOffset = 0
                    popupOpacity = 1
                }
            }
        }
    }
    
    private func sendRecoveryEmail() {
        isLoading = true
        errorMessage = ""
        
        // Simulate API call to Firebase - in a real app, use Firebase Auth
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            
            // Success scenario - in a real app check for Firebase errors
            if isValidEmail {
                emailSent = true
            } else {
                errorMessage = getTranslation(for: "invalidEmail")
            }
        }
    }
    
    private func closePopup() {
        withAnimation(.easeOut(duration: 0.3)) {
            popupOffset = 300
            popupOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showPopup = false
        }
    }
}

// Preview
struct PasswordRecoveryPopup_Previews: PreviewProvider {
    static var previews: some View {
        PasswordRecoveryPopup(recoveryEmail: .constant(""), language: "English", showPopup: .constant(true))
            .preferredColorScheme(.light)
    }
}
