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
    let icon: String?
    let label: String?
    let autoCapitalization: TextInputAutocapitalization = .never
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textInputAutocapitalization(autoCapitalization)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(autoCapitalization)
                }
            }
            .padding()
            .background(.primaryBackground)
            .cornerRadius(8)
        }
    }
}

