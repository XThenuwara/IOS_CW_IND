import SwiftUI

struct SignUp: View {
    @ObservedObject private var authModel = AuthCoreDataModel.shared
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Join us to discover and share amazing events")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            // Form Fields
            VStack(spacing: 16) {
                InputField(
                    text: $fullName,
                    placeholder: "Full name",
                    icon: "person.fill",
                    label: nil
                )
                
                InputField(
                    text: $email,
                    placeholder: "Email or phone number",
                    icon: "envelope.fill",
                    label: nil
                )
                
                InputField(
                    text: $password,
                    placeholder: "Password",
                    icon: "lock.fill",
                    label: nil,
                    isSecure: true
                )
                
                InputField(
                    text: $confirmPassword,
                    placeholder: "Confirm password",
                    icon: "lock.fill",
                    label: nil,
                    isSecure: true
                )
            }
            
            // Terms and Privacy
            VStack(spacing: 8) {
                Text("By creating an account, you agree to our:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Button("Terms of Service") {
                       
                    }
                    Text("•")
                        .foregroundColor(.gray)
                    Button("Privacy Policy") {
                        
                    }
                }
                .font(.caption)
            }
            
            // Sign Up Button
            Button(action: handleSignUp) {
                Text("Create Account")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Sign In Link
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                Button("Sign in") {
                    dismiss()
                }
            }
            .font(.subheadline)
        }
        .padding()
    }
    
    @State private var showError = false
        @State private var errorMessage = ""
        
        private func handleSignUp() {
            guard password == confirmPassword else {
                withAnimation {
                    errorMessage = "Passwords do not match"
                    showError = true
                }
                return
            }
            
            authModel.signup(name: fullName, email: email, password: password) { result in
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    withAnimation {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
}


#Preview {
    SignUp()
}
