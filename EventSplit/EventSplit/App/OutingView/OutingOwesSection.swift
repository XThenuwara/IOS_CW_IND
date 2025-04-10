import SwiftUI

struct OutingOwesSection: View {
    let users: [UserDTO]
    let participants: [ParticipantDTO]
    let debts: [DebtEntity]
    let totalBudget: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("Outstanding Balances")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Choose how you want to settle your balances. Pay through the app for instant settlement, or mark as paid if you've paid outside.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Balances List
            ParticipantDebtList(
                users: users,
                participants: participants,
                debts: debts
            )
            
            // Footer
            VStack(spacing: 12) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "dollarsign")
                        Text("Settle Up All Debts ($\(String(format: "%.2f", totalBudget)))")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Text("Secure payments powered by Stripe")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("In-app payments are processed instantly. Manual settlements need to be confirmed by both parties.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

