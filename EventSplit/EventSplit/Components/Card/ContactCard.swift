//
//  ContactCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI
import ContactsUI

struct ContactCard: View {
    let contact: CNContact
    let onInvite: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                
                Text(String(contact.givenName.prefix(1)))
                    .font(.subheadline)
                    .foregroundColor(.secondaryBackground)
            }
            
            // Contact Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(contact.givenName) \(contact.familyName)")
                    .font(.headline)
                
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    Text(phoneNumber)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                Button(action: onInvite) {
                    Image(systemName: "envelope")
                        .font(.system(size: 14))
                        .padding(6)
                        .background(Color.white)
                        .foregroundColor(.secondaryBackground)
                        .clipShape(Circle())
                }
                
                Button(action: onDelete) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .padding(6)
                        .background(Color.white)
                        .foregroundColor(.secondaryBackground)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(.primaryBackground)
        .cornerRadius(12)
    }
}
