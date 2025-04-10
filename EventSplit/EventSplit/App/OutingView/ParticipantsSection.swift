import SwiftUI

struct ParticipantsSection: View {
    let users: [UserDTO]
    let activities: [ActivityDTO]
    @State private var showInvite = false
    
    private var participantAmounts: [(user: UserDTO, amount: Double, status: String)] {
        users.map { user in
            let paidAmount = activities
                .filter { $0.paidById == user.id.uuidString }
                .reduce(0.0) { $0 + (Double($1.amount) ?? 0.0) }
            
            // Default to "Confirmed" for now, you can add actual status logic later
            let status = "Confirmed"
            
            return (user: user, amount: paidAmount, status: status)
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
                    ForEach(users.prefix(3), id: \.id) { user in
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(user.name.prefix(1))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            )
                    }
                    if users.count > 3 {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("+\(users.count - 3)")
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
                }
            }
            
            // Participant List
            VStack(spacing: 12) {
                ForEach(participantAmounts, id: \.user.id) { participant in
                    HStack {
                        // Avatar and Info
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(.systemGray5))
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
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Amount
                        Text("$\(String(format: "%.2f", participant.amount))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .sheet(isPresented: $showInvite) {
            // TODO: Implement invite sheet
            Text("Invite Participants")
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
            activities: []
        )
    }
}