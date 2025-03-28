import SwiftUI

struct Login: View {
    @ObservedObject private var authModel = AuthCoreDataModel.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showSignUp = false
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sign in to continue your journey")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Form Fields
                VStack(spacing: 16) {
                    InputField(
                        text: $email,
                        placeholder: "Email or phone number",
                        icon: "envelope.fill"
                    )
                    
                    InputField(
                        text: $password,
                        placeholder: "Password",
                        icon: "lock.fill",
                        isSecure: true
                    )
                    
                    Button("Forgot Password?") {
                        // TODO:  Handle forgot password
                    }
                    
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                            
            if showError {
                ErrorCard(
                    message: errorMessage,
                    isVisible: showError,
                    onDismiss: { showError = false }
                )
            }

                // Sign In Button
                Button(action: handleSignIn) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Button("Sign up") {
                        showSignUp = true
                    }
                }
                .font(.subheadline)
            }
            .padding()
            .sheet(isPresented: $showSignUp) {
                SignUp()
            }
        }
    }
    
    private func handleSignIn() {
        Task {
            await MainActor.run {
                authModel.login(email: email.lowercased(), password: password) { result in
                    switch result {
                    case .success:
                        dismiss()
                    case .failure(let error):
                        withAnimation {
                            showError = true
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Login()
}
