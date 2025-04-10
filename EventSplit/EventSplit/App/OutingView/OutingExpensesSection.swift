import SwiftUI

struct OutingExpensesSection: View {
    let users: [UserDTO]
    let activities: [ActivityDTO]
    let totalBudget: Double
    let yourShare: Double
    let onAddExpense: () -> Void
    @State private var currentUser: UserDTO? = AuthCoreDataModel.shared.currentUser
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expenses")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("\(activities.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onAddExpense) {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign")
                            .font(.system(size: 14))
                        Text("Add Expense")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .clipShape(Capsule())
                }
            }
            
            // Expenses List
            VStack(spacing: 3) {
                ForEach(activities, id: \.id) { activity in
                    OutingExpenseRow(users: users, activity: activity)
                    if activity.id != activities.last?.id {
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
            }
            
            // Summary Card
            OutingSummaryCard(
                totalBudget: totalBudget,
                yourShare: calculateYourShare()
            )
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

    private func calculateYourShare() -> Double {
        var yourShare = 0.0
        guard let currentUserId = currentUser?.id.uuidString.lowercased() else { return 0.0 }
        
        for activity in activities {
            if activity.participants.contains(where: { $0.lowercased() == currentUserId }) {
                let participantCount = Double(activity.participants.count)
                yourShare += activity.amount / participantCount
            }
        }
        return yourShare
    }
}

