import SwiftUI

struct OutingExpenseRow: View {
    let users: [UserDTO]
    let activity: ActivityDTO
    
    init(users: [UserDTO], activity: ActivityDTO) {
        self.users = users
        self.activity = activity
    }

    var body: some View {
        HStack(spacing: 12) {
            // Avatar circle
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                Image(systemName: "receipt")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .frame(width: 32, height: 32)
            
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paid by \(users.first { $0.id.uuidString.lowercased() == activity.paidById?.lowercased() }?.name ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Participants
                    HStack(spacing: -4) {
                        ForEach(activity.participants, id: \.self) { participant in
                            let user = users.first { $0.id.uuidString.lowercased() == participant.lowercased() }
                            Circle()
                                .fill(Color(.systemGray5))
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Text(String(user?.name.prefix(1) ?? participant.prefix(1)))
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color(.systemBackground), lineWidth: 1)
                                )
                        }
                    }
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(String(format: "%.2f", activity.amount))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("$\(String(format: "%.2f", activity.amount / Double(activity.participants.count))) / person")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}
