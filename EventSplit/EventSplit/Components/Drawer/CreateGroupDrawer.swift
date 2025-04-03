import SwiftUI
import ContactsUI

struct CreateGroupDrawer: View {
    @State private var groupName: String = ""
    @State private var description: String = ""
    @State private var selectedContacts: [CNContact] = []
    @State private var showInviteMemberDrawer = false
    @Environment(\.dismiss) private var dismiss

    private func createGroup() {
        // Mock implementation
        print("Creating group with:")
        print("Name: \(groupName)")
        print("Description: \(description)")
        print("Members: \(selectedContacts.count)")
        
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
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                // Group Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Group Name")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("Enter group name", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("What's this group about?", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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
                        .background(Color(.systemGray6))
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
                    .background(Color(.systemBlue))
                    .cornerRadius(12)
            }
        }
        .padding()
        .sheet(isPresented: $showInviteMemberDrawer) {
            InviteMemberDrawer { contacts in
                selectedContacts = contacts
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
    
