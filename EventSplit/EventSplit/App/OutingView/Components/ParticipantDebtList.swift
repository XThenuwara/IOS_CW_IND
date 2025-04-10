import SwiftUI

struct ParticipantDebtList: View {
    let users: [UserDTO]
    let participants: [ParticipantDTO]
    let debts: [DebtEntity]
    
    private var processedDebts: [Debt] {
        debts.map { debtEntity in
            Debt(
                from: debtEntity.fromUserId ?? "",
                to: debtEntity.toUserId ?? "",
                amount: debtEntity.amount
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if processedDebts.isEmpty {
                Text("All debts are settled")
                    .foregroundColor(.secondary)
            } else {
                ForEach(processedDebts, id: \.self) { debt in
                    DebtRow(debt: debt, users: users)
                }
            }
        }
    }

}

struct Debt: Hashable {
    let from: String
    let to: String
    let amount: Double
}

struct DebtRow: View {
    let debt: Debt
    let users: [UserDTO]
    
    private var fromUser: UserDTO? {
        users.first { $0.id.uuidString.lowercased() == debt.from.lowercased() }
    }
    
    private var toUser: UserDTO? {
        users.first { $0.id.uuidString.lowercased() == debt.to.lowercased() }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Avatar and Info
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(fromUser?.name.prefix(2) ?? "NA")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(fromUser?.name ?? "Unknown") → \(toUser?.name ?? "Unknown")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(fromUser?.name ?? "Unknown") owes \(toUser?.name ?? "Unknown")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Amount
                Text("$\(String(format: "%.2f", debt.amount))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
            }
            
            // Buttons Row
            HStack(spacing: 8) {
                Spacer()
                Button(action: {}) {
                    Text("Mark as Paid")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign")
                        Text("Pay Now")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
