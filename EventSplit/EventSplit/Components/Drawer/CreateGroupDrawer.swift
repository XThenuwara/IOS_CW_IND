//
//  CreateGroupDrawer.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI
import ContactsUI

struct CreateGroupDrawer: View {
    @State private var groupName: String = ""
    @State private var description: String = ""
    @State private var selectedContacts: [CNContact] = []
    @State private var showInviteMemberDrawer = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    private func createGroup() {
         if groupName.isEmpty {
            errorMessage = "Please enter a group name"
            showError = true
            return
        }
        
        if selectedContacts.isEmpty {
            errorMessage = "Please select at least one member"
            showError = true
            return
        }


        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Mock success
            print("Group created successfully!")
            dismiss()
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Create New Group")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                // Group Name
                VStack(alignment: .leading, spacing: 8) {
                    InputField(
                        text: $groupName,
                        placeholder: "Enter group name",
                        icon: "person.2.circle",
                        label: "Group Name"
                    )
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    InputField(
                        text: $description,
                        placeholder: "What's this group about?",
                        icon: "text.alignleft",
                        label: "Description"
                    )
                }
                
                // Add Members
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add Members")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button(action: { showInviteMemberDrawer = true }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Select Members")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.secondaryBackground)
                        .background(.primaryBackground)
                        .cornerRadius(8)
                    }
                    
                    // Selected Members List
                    if !selectedContacts.isEmpty {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(selectedContacts, id: \.identifier) { contact in
                                    HStack {
                                        Text(String(contact.givenName.prefix(1)))
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .frame(width: 32, height: 32)
                                            .background(Circle().fill(Color.blue))
                                        
                                        VStack(alignment: .leading) {
                                            Text("\(contact.givenName) \(contact.familyName)")
                                                .font(.subheadline)
                                            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                                                Text(phoneNumber)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            selectedContacts.removeAll { $0.identifier == contact.identifier }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
            }
            
            Spacer()
            // Create Group Button
            Button(action: createGroup) {
                Text("Create Group")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.primaryBackground)
                    .background(.secondaryBackground)
                    .cornerRadius(12)
            }
        }
        .padding()
                .overlay(
            ErrorCard(
                message: errorMessage,
                isVisible: showError,
                onDismiss: { showError = false }
            )
        )
        .sheet(isPresented: $showInviteMemberDrawer) {
            DrawerModal(isOpen: $showInviteMemberDrawer) {
                     InviteMemberDrawer { contacts in
                selectedContacts = contacts
            }
            }
        }
    }
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
}

#Preview {
    CreateGroupDrawer()
}
