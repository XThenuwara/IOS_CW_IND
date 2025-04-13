//
//  InviteMemberDrawer.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-02.
//
import SwiftUI
import ContactsUI
import MessageUI

struct InviteMemberDrawer: View {
    let onComplete: ([CNContact]) -> Void
    @State private var selectedContacts: [CNContact] = []
    @State private var contacts: [CNContact] = []
    @State private var showContactPicker = false
    @State private var selectedContact: CNContact?
    @State private var showShareSheet = false
    @State private var showMailComposer = false
    @State private var showMessageComposer = false
    @Environment(\.dismiss) private var dismiss
    
    // Update the body property
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Invite Members")
                .font(.title2)
                .fontWeight(.bold)
            
            ContactListView(
                selectedContacts: $selectedContacts,
                showShareSheet: $showShareSheet,
                selectedContact: $selectedContact,
                contacts: contacts
            )
            
            Spacer()
            
            // Invite Options
            VStack(spacing: 16) {
                Button(action: { showContactPicker = true }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Select from Contacts")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.secondaryBackground)
                    .foregroundColor(.primaryBackground)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    onComplete(selectedContacts)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Done")
                              .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.primaryBackground)
                    .foregroundColor(.secondaryBackground)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .onAppear(perform: requestContactsAccess)
        .sheet(isPresented: $showContactPicker) {
            ContactPickerViewController(selectedContact: Binding(
                get: { selectedContact },
                set: { contact in
                    if let contact = contact {
                        selectedContact = contact
                        if !selectedContacts.contains(where: { $0.identifier == contact.identifier }) {
                            selectedContacts.append(contact)
                        }
                    }
                }
            ))
        }
        .sheet(isPresented: $showShareSheet) {
            if let contact = selectedContact {
                ShareSheet(activityItems: [createInviteMessage(for: contact)])
            }
        }
    }

    
    
    private func requestContactsAccess() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else { return }
            
            let keys = [CNContactGivenNameKey, CNContactFamilyNameKey,
                        CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
            let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    var allContacts: [CNContact] = []
                    try store.enumerateContacts(with: request) { contact, _ in
                        allContacts.append(contact)
                    }
                    DispatchQueue.main.async {
                        self.contacts = allContacts
                    }
                } catch {
                    print("Error fetching contacts: \(error)")
                }
            }
        }
    }
    
    private func createInviteMessage(for contact: CNContact) -> String {
        return "Hey \(contact.givenName), join me on EventSplit to split expenses easily! Download here: [App Store Link]"
    }
    
    private func shareInviteLink() {
        showShareSheet = true
    }
}

// Add at the end of the file
#Preview {
    InviteMemberDrawer { contacts in
        print("Selected contacts: \(contacts.count)")
    }
    .preferredColorScheme(.light)
    .environment(\.colorScheme, .light)
}
