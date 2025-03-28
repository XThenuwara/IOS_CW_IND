import SwiftUI

struct OutingCard: View {
    let outing: OutingEntity
    
    private var title: String { outing.title ?? "Untitled" }
    private var description: String { outing.desc ?? "" }
    private var participants: Int {
        guard let participantsJson = outing.participants,
              let data = participantsJson.data(using: .utf8),
              let participants = try? JSONDecoder().decode([UserDTO].self, from: data) else {
            return 0
        }
        return participants.count
    }
    private var totalExpense: Double { outing.totalExpense }
    private var youOwe: Double { totalExpense / Double(max(participants, 1)) }
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
    
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    StatusBadge(status: status)
                }
                
                // Location and Details
                HStack(spacing: 16) {
                    
                    // Participants
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .foregroundColor(.gray)
                        Text("\(participants)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Events
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.gray)
                        Text("\(eventsCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    // Activities
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
                // Expense Info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Expense")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("$\(String(format: "%.2f", totalExpense))")
                        .font(.system(size: 14, weight: .medium))
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("You Owe")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text("$\(String(format: "%.2f", youOwe))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(action: {
                    // Handle add expense action
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
    }
}

struct StatusBadge: View {
    let status: OutingStatus
    
    var backgroundColor: Color {
        switch status {
        case .draft: return Color.gray.opacity(0.2)
        case .inProgress: return Color.yellow.opacity(0.2)
        case .unsettled: return Color.orange.opacity(0.2)
        case .settled: return Color.green.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch status {
        case .draft: return .gray
        case .inProgress: return .yellow
        case .unsettled: return .orange
        case .settled: return .green
        }
    }
    
    var displayText: String {
        switch status {
        case .draft : return "Draft"
        case .inProgress: return "In Progress"
        case .unsettled: return "Unsettled"
        case .settled: return "Settled"
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let outing = OutingEntity(context: context)
    outing.id = UUID()
    outing.title = "Weekend Camping"
    outing.desc = "Fun weekend getaway"
    outing.totalExpense = 950.00
    outing.status = "in_progress"
    outing.participants = "[{id: 1}]"
    outing.linkedEvents =  "[{id: 1}]"
    
    return OutingCard(outing: outing)
        .padding()
}
