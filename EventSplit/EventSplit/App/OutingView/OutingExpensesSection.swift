//
//  OutingExpensesSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-29.
//
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
                        Image(systemName: "plus")
                            .font(.system(size: 14))
                        Text("Add Expense")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.primaryBackground)
                    .foregroundColor(.secondaryBackground)
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
        .withBorder()
        .withShadow()
        .padding(.horizontal)
    }

    private func calculateYourShare() -> Double {
        var yourShare = 0.0
        guard let currentUserId = currentUser?.id.uuidString.lowercased() else { return 0.0 }
        
        for activity in activities {
            // Add your share if you're a participant
            if activity.participants.contains(where: { $0.lowercased() == currentUserId }) {
                let participantCount = Double(activity.participants.count)
                yourShare += activity.amount / participantCount
            }
            
            // Subtract the full amount if you paid for it
            if activity.paidById?.lowercased() == currentUserId {
                yourShare -= activity.amount
            }
        }
        return yourShare
    }
}

