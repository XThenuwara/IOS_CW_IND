//
//  ParticipantsSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-13.
//
import SwiftUI
import ContactsUI

struct ParticipantsSection: View {
    let users: [UserDTO]
    let activities: [ActivityDTO]
    let outingId: String
    let outingService = OutingService(coreDataModel: OutingCoreDataModel())
    @State private var showInvite = false
    @State private var updatedUsers: [UserDTO]
    @State private var showDeleteAlert = false
    @State private var participantToDelete: UserDTO?

    init(users: [UserDTO], activities: [ActivityDTO], outingId: String) {
        self.users = users
        self.activities = activities
        self.outingId = outingId
        _updatedUsers = State(initialValue: users)
    }

    private var participantAmounts: [(user: UserDTO, amount: Double, status: String)] {
        (updatedUsers.isEmpty ? users : updatedUsers).map { user in
            let paidAmount = activities
                .filter { $0.paidById == user.id.uuidString }
                .reduce(0.0) { $0 + (Double($1.amount) ?? 0.0) }
            
            let status = "Pending"
            
            return (user: user, amount: paidAmount, status: status)
        }
    }
    
    private func updateParticipantsList(participants: [UserDTO]) {
        updatedUsers = participants
        
        let participantDTOs = participants.map { 
            ParticipantDTO(
                id: $0.id.uuidString, 
                name: $0.name, 
                email: $0.email, 
                phoneNumber: $0.phoneNumber
            ) 
        }
        
        outingService.updateParticipants(outingId: outingId, participants: participantDTOs) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Failed to update participants: \(error)")
            }
        }
    }
    
    private func addParticipants(with contacts: [CNContact]) {
        let newUsers = contacts.map { contact in
            UserDTO(
                id: UUID(),
                name: contact.givenName,
                email: contact.emailAddresses.first?.value as String? ?? "",
                phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? ""
            )
        }
        
        var combinedUsers = users
        combinedUsers.append(contentsOf: newUsers)
        updateParticipantsList(participants: combinedUsers)
    }
    
    private func deleteParticipant(_ user: UserDTO) {
        var updatedParticipants = users
        if let index = updatedParticipants.firstIndex(where: { $0.id == user.id }) {
            updatedParticipants.remove(at: index)
            updateParticipantsList(participants: updatedParticipants)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Participants")
                    .font(.headline)
                
                // Participant avatars
                HStack(spacing: -8) {
                    ForEach(updatedUsers.prefix(3), id: \.id) { user in
                        Circle()
                            .fill(.primaryBackground)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(user.name.prefix(1))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            )
                    }
                    if updatedUsers.count > 3 {
                        Circle()
                            .fill(.primaryBackground)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("+\(updatedUsers.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                
                Spacer()
                
                Button(action: { showInvite = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Invite")
                            .font(.subheadline)
                    }
                    .padding(.all, 4)
                    .padding(.horizontal, 8)
                    .background(.primaryBackground)
                    .foregroundColor(.secondaryBackground)
                    .cornerRadius(100)
                }
            }
            
            // Participant List
            VStack(spacing: 12) {
                ForEach(participantAmounts, id: \.user.id) { participant in
                    HStack {
                        // Avatar and Info
                        HStack(spacing: 12) {
                            Circle()
                                .fill(.primaryBackground)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(participant.user.name.prefix(1))
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(participant.user.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text(participant.status)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // Amount
                        if participant.amount > 0 {
                            Text("$\(String(format: "%.2f", participant.amount))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Delete Button
                        Button(action: {
                            participantToDelete = participant.user
                            showDeleteAlert = true
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        }
                    }
                }
            }
        }
        .padding()
        .background(.highLightBackground)
        .cornerRadius(16)
        .withShadow()
        .withBorder()
        .padding(.horizontal)
        .sheet(isPresented: $showInvite) {
            DrawerModal(isOpen: $showInvite) {
                InviteMemberDrawer { contacts in
                    addParticipants(with: contacts)
                }
            }
        }
        .alert("Remove Participant", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                if let user = participantToDelete {
                    deleteParticipant(user)
                }
            }
        } message: {
            Text("Are you sure you want to remove this participant?")
        }
    }
}

struct ParticipantsSection_Previews: PreviewProvider {
    static var previews: some View {
        ParticipantsSection(
            users: [
                UserDTO(id: UUID(), name: "John Doe", email: "john@example.com", phoneNumber: "1234567890"),
                UserDTO(id: UUID(), name: "Jane Smith", email: "jane@example.com", phoneNumber: "0987654321")
            ],
            activities: [],
            outingId: "sample-outing-id"
        )
    }
}
