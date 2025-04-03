import SwiftUI
import ContactsUI

struct ContactListView: View {
    @Binding var selectedContacts: [CNContact]
    @Binding var showShareSheet: Bool
    @Binding var selectedContact: CNContact?
    let contacts: [CNContact]
    
    var body: some View {
        VStack(spacing: 20) {
            // Selected Contacts
            if !selectedContacts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(selectedContacts, id: \.identifier) { contact in
                                ContactCard(
                                    contact: contact,
                                    onInvite: {
                                        selectedContact = contact
                                        showShareSheet = true
                                    },
                                    onDelete: {
                                        selectedContacts.removeAll { $0.identifier == contact.identifier }
                                    }
                                )
                                .padding(.horizontal, 2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            // Contacts List
        }
    }
}
