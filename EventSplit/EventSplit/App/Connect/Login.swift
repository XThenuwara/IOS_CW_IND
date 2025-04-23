//
//  Login.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-02.
//
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
            Color.primaryBackground
                .ignoresSafeArea()
            
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
                        icon: "envelope.fill",
                        label: nil,
                        highlight: true
                    )
                    
                    InputField(
                        text: $password,
                        placeholder: "Password",
                        icon: "lock.fill",
                        label: nil,
                        isSecure: true,
                        highlight: true
                    )
                    
                    Button("Forgot Password?") {
                        // TODO:  Handle forgot password
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.secondaryBackground)
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
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.secondaryBackground)
                        .foregroundColor(.primaryBackground)
                        .cornerRadius(8)
                }
                
                // Sign Up Link
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Button("Sign up") {
                        showSignUp = true
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.secondaryBackground)
                }
                .font(.subheadline)
                
                // #if DEBUG
                // Spacer()
                // Button(action: {
                //     email = "john@example.com"
                //     password = ""
                //     handleSignIn()
                // }) {
                //     Text("Debug Login")
                //         .font(.caption)
                //         .padding(.horizontal, 12)
                //         .padding(.vertical, 6)
                //         .background(Color.gray.opacity(0.1))
                //         .foregroundColor(.gray)
                //         .cornerRadius(8)
                // }
                // #endif
            }
            .padding()
            .background(.primaryBackground)
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
