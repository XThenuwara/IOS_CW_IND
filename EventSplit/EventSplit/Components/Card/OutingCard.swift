//
//  OutingCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-22.
//
import SwiftUI

struct OutingCard: View {
    let outing: OutingDTO
    @State private var showAddExpenseSheet = false
    
    private var title: String { outing.title }
    private var description: String { outing.description }
    private var participants: Int { outing.participants.count }
    private var totalExpense: Double {
        let activities = outing.activities ?? []
        return activities.reduce(0.0) { sum, activity in
            sum + activity.amount
        }
    }
    private var status: OutingStatus { outing.status }
    private var eventsCount: Int { outing.outingEvents?.count ?? 0 }
    private var activitiesCount: Int { outing.activities?.count ?? 0 }
    
    @State private var currentUser: UserDTO? = AuthCoreDataModel.shared.currentUser
    
    private func calculateYourShare() -> Double {
        guard let currentUserId = currentUser?.id.uuidString.lowercased() else { return 0.0 }
        var yourShare = 0.0
        
        for activity in outing.activities ?? [] {
            if activity.participants.contains(where: { $0.lowercased() == currentUserId }) {
                let participantCount = Double(activity.participants.count)
                yourShare += activity.amount / participantCount
            }
            
            if activity.paidById?.lowercased() == currentUserId {
                yourShare -= activity.amount
            }
        }
        return yourShare
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    StatusBadge(text: status.rawValue)
                }
                
                // Location and Details
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .foregroundColor(.gray)
                        Text("\(participants)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.gray)
                        Text("\(eventsCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.gray)
                        Text("\(activitiesCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Divider()
            
            // Footer
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Expense")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("$\(String(format: "%.2f", totalExpense))")
                        .font(.system(size: 14, weight: .medium))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(calculateYourShare() < 0 ? "You Get" : "You Owe")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("$\(String(format: "%.2f", abs(calculateYourShare())))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(calculateYourShare() < 0.01 ? .green : .red)
                }
                
                Spacer()
                
                Button(action: {
                    showAddExpenseSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Expense")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.primaryBackground)
                    .foregroundColor(.secondaryBackground)
                    .cornerRadius(20)
                }
            }
        }
        .padding(16)
        .background(.highLightBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .sheet(isPresented: $showAddExpenseSheet) {
            DrawerModal(isOpen: $showAddExpenseSheet) {
                AddExpenseDrawer(outing: outing, onSuccess: {})
                    .presentationDetents([.large])
            }
        }
    }
}

#Preview {
    OutingCard(
        outing: OutingDTO(
            id: UUID(),
            title: "Weekend Camping",
            description: "Fun weekend getaway",
            owner: UserDTO(id: UUID(), name: "Owner", email: "owner@example.com", phoneNumber: "1234567890"),
            participants: [
                ParticipantDTO(id: "123124541", name: "John", email: "john@example.com", phoneNumber: "+94771234567"),
                ParticipantDTO(id: "123124542", name: "Jane", email: "jane@example.com", phoneNumber: "+94771234568")
            ],
            activities: [],
            outingEvents: [],
            debts: [],
            status: .draft,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    )
    .padding()
}
