//
//  OutingExpenseRow.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-29.
//
import SwiftUI

struct OutingExpenseRow: View {
    let users: [UserDTO]
    let activity: ActivityDTO
    @State private var showExpenseDetails = false
    
    init(users: [UserDTO], activity: ActivityDTO) {
        self.users = users
        self.activity = activity
    }

    var body: some View {
        Button(action: {
            showExpenseDetails = true
        }) {
            HStack(spacing: 12) {                
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
                                    .fill(Color(.primaryBackground))
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
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showExpenseDetails) {
            DrawerModal(isOpen: $showExpenseDetails) {
                ExpenseViewDrawer(users: users, activity: activity)
            }
        }
    }
}
