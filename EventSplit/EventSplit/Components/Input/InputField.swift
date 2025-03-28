//
//  InputField.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-28.
//
import SwiftUI

struct InputField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    let autoCapitalization: TextInputAutocapitalization = .never
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(autoCapitalization)
            } else {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(autoCapitalization)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

