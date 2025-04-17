//
//  OutingCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-22.
//
import SwiftUI

struct OutingCard: View {
    let outing: OutingEntity
    @State private var showAddExpenseSheet = false
    
    private var title: String { outing.title ?? "Untitled" }
    private var description: String { outing.desc ?? "" }
    private var participants: Int {
        guard let participantsJson = outing.participants else {
            print("No participants JSON found")
            return 0
        }
        
        do {
        
            let participantStrings = try JSONDecoder().decode([String].self, from: participantsJson.data(using: .utf8)!)
           
            let participants = try participantStrings.compactMap { participantString -> ParticipantDTO? in
                guard let data = participantString.data(using: .utf8) else { return nil }
                return try JSONDecoder().decode(ParticipantDTO.self, from: data)
            }
            
            return participants.count
        } catch {
            print("[OutingCard.ParticipantsDecode] Error decoding participants:", error)
            return 0
        }
    }
    private var totalExpense: Double { outing.totalExpense }
    private var youOwe: Double { outing.due }
    private var status: OutingStatus {
        OutingStatus(rawValue: outing.status ?? "in_progress") ?? .inProgress
    }
    
    
    private var eventsCount: Int {
        guard let eventsJson = outing.linkedEvents,
              let data = eventsJson.data(using: String.Encoding.utf8),
              let events = try? JSONDecoder().decode([OutingEventDTO].self, from: data) else {
            return 0
        }
        return events.count
    }
    
    private var activitiesCount: Int {
        guard let activitiesJson = outing.activities,
              let data = activitiesJson.data(using: .utf8),
              let activities = try? JSONDecoder().decode([ActivityDTO].self, from: data) else {
            return 0
        }
        return activities.count
    }
    
    @State private var currentUser: UserDTO? = AuthCoreDataModel.shared.currentUser
    
    private func calculateYourShare() -> Double {
        var yourShare = 0.0
        guard let currentUserId = currentUser?.id.uuidString.lowercased() else { return 0.0 }
        
        guard let activitiesJson = outing.activities,
              let data = activitiesJson.data(using: .utf8),
              let activities = try? JSONDecoder().decode([ActivityDTO].self, from: data) else {
            return 0.0
        }
        
        for activity in activities {
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
            .foregroundColor(calculateYourShare() < 0 ? .green : .red)
    }
                
                Spacer()
                
                Button(action: {
                    showAddExpenseSheet = true 
                }) {
                    Text("Add Expense")
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
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .sheet(isPresented: $showAddExpenseSheet) {
            DrawerModal(isOpen: $showAddExpenseSheet) {
                AddExpenseDrawer(outing: outing)
                    .presentationDetents([.large])
            }
        }
    }
}



#Preview {
    let context = PersistenceController.preview.container.viewContext
    let outing = OutingEntity(context: context)
    outing.id = UUID(uuidString: "6a8d5990-40ea-4eb8-91bf-18a6542dd36c")
    outing.title = "Weekend Camping"
    outing.desc = "Fun weekend getaway"
    outing.totalExpense = 950.00
    outing.status = "in_progress"
    outing.participants = "[{\"id\": \"123124541\", \"name\": \"John\", \"email\": \"john@example.com\", \"phoneNumber\": \"+94771234567\"}, {\"id\": \"123124542\", \"name\": \"Jane\", \"email\": \"jane@example.com\", \"phoneNumber\": \"+94771234568\"}]"
    outing.linkedEvents = "[{id: 1}]"
    
    return OutingCard(outing: outing)
        .padding()
}
