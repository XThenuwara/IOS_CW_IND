//
//  CreateOutingDrawer.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-29.
//
import SwiftUI
import ContactsUI

struct CreateOutingDrawer: View {
    @Environment(\.dismiss) var dismiss
    let onSuccess: (() -> Void)?
    @State private var buttonState: ActionButtonState = .default
    @StateObject private var eventCoreData = EventCoreDataModel()
    @StateObject private var outingStore = OutingCoreDataModel()
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showEventPicker = false
    @State private var selectedEventId: UUID? = nil
    @State private var showInviteMemberDrawer = false
    @State private var selectedContacts: [CNContact] = []
    
    var body: some View {
        VStack(spacing: 20) {
            HStack() {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create New Outing")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.secondaryBackground)
                    Text("Plan and organize your event with friends")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Title Input
            InputField(
                text: $title,
                placeholder: "Enter outing title",
                icon: "pencil",
                label: "Title",
                highlight: true
            )
            
            // Description Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .background(.primaryBackground)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.2), lineWidth: 1)
                    )
            }
            
            
            // Selected Event
            if let eventId = selectedEventId,
               let event = eventCoreData.eventStore.first(where: { $0.id == eventId }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Event")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title ?? "Unknown")
                                .font(.headline)
                            if let date = event.eventDate {
                                Text(date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Text(event.locationName ?? "Unknown location")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedEventId = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Event Selection
            HStack(spacing: 8) {
                Text("Event")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    showEventPicker.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text(selectedEventId == nil ? "Select Event" : "Change Event")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondaryBackground.opacity(0.1))
                    .foregroundColor(.secondaryBackground)
                    .cornerRadius(16)
                }
                
            }
            
            // Members Section
            HStack(spacing: 8) {
                Text("Members")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    showInviteMemberDrawer = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.badge.plus")
                        Text("Invite Members")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondaryBackground.opacity(0.1))
                    .foregroundColor(.secondaryBackground)
                    .cornerRadius(16)
                }
            }
            
            if selectedContacts.isEmpty {
                
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedContacts, id: \.identifier) { contact in
                            HStack {
                                Text("\(contact.givenName) \(contact.familyName)")
                                    .font(.caption)
                                Button(action: {
                                    selectedContacts.removeAll { $0.identifier == contact.identifier }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            showInviteMemberDrawer = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Create Button
            ActionButton(
                title: "Create Outing",
                action: createOuting,
                state: buttonState,
                fullWidth: true
            )
            .disabled(title.isEmpty || description.isEmpty)
            
            .disabled(title.isEmpty || description.isEmpty)
            
            Text("Once created, you can invite members and manage the outing details")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom)
        }
        .padding()
        .sheet(isPresented: $showEventPicker) {
            EventPickerView(selectedEvents: Binding(
                get: { selectedEventId.map { Set([$0]) } ?? Set() },
                set: { selectedEventId = $0.first }
            ))
        }
        .sheet(isPresented: $showInviteMemberDrawer) { 
            DrawerModal(isOpen: $showInviteMemberDrawer) {
                InviteMemberDrawer { contacts in
                    selectedContacts = contacts
                }
            }
        }
        .onAppear {
            eventCoreData.fetchEventsFromServer()
        }
    }
    
    private func createOuting() {
        buttonState = .loading
        let selectedEvent = selectedEventId.flatMap { eventId in
            eventCoreData.eventStore.first { $0.id == eventId }
        }
        
        let participants = OutingHelperService.shared.convertParticipantsToJSON(selectedContacts)
        
        
        // Create outing without event
        outingStore.createNewOuting(
            title: title,
            description: description,
            event: selectedEvent,
            participants: participants
        )
        buttonState = .success
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            dismiss()
            onSuccess?()
        }
    }
}

struct EventChip: View {
    let title: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}


#Preview {
    CreateOutingDrawer(onSuccess: nil)
}
