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
            // Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField("Enter outing title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            
            // Description Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
            VStack(alignment: .leading, spacing: 8) {
                Text("Event")  // Changed to singular
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showEventPicker.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(selectedEventId == nil ? "Select Event" : "Change Event")  // Updated text
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Members Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Members")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if selectedContacts.isEmpty {
                    Button(action: {
                        showInviteMemberDrawer = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Invite Members")
                        }
                        .foregroundColor(.blue)
                    }
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
            }
            
            Spacer()
            
            // Create Button
            Button(action: {
                createOuting()
            }) {
                Text("Create Outing")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(title.isEmpty || description.isEmpty)
        }
        .padding()
        .sheet(isPresented: $showEventPicker) {
            EventPickerView(selectedEvents: Binding(
                get: { selectedEventId.map { Set([$0]) } ?? Set() },
                set: { selectedEventId = $0.first }
            ))
        }
        .sheet(isPresented: $showInviteMemberDrawer) {  // Add this
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
        let selectedEvent = selectedEventId.flatMap { eventId in
            eventCoreData.eventStore.first { $0.id == eventId }
        }
        
        let participants = OutingHelperService.shared.convertParticipantsToJSON(selectedContacts)
        
        outingStore.createNewOuting(
            title: title,
            description: description,
            event: selectedEvent,
            participants: participants
        )

        CalendarService.shared.addEventToCalendar(
            title: title,
            description: description,
            startDate: selectedEvent?.eventDate
        ) { success in
            if !success {
                print("❌ Failed to add event to calendar")
            }
            dismiss()
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
    CreateOutingDrawer()
}
