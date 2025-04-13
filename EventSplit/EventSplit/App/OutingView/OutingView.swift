//
//  OutingView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-25.
//
import SwiftUI

struct OutingView: View {
    let outing: OutingEntity
    @StateObject private var outingCoreDataModel = OutingCoreDataModel()
    @State private var showAddExpense = false
    @State private var users: [UserDTO] = []
    
    init(outing: OutingEntity) {
        print("[OutingView] Outing ID:", outing)
        self.outing = outing
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(outing.title ?? "Outing")")
                            .font(.system(size: 28, weight: .bold))
                        Text("Discover events happening in your area")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    
                    Spacer()
                    
                    Button(action: { showAddExpense = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 14))
                            Text("Add Expense")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.primary)
                        .foregroundColor(Color.primaryBackground)
                        .clipShape(Capsule())
                    }
                }
                .padding()
                
                // Calendar Check
                if let eventData = outing.outingEvent?.event {
                    OutingEventCard(outingEntity: outing,eventData: eventData)
                }
                
                // Calendar Check
                OutingCalendarCheck(
                    title: outing.title ?? "",
                    description: outing.desc ?? "",
                    startDate: outing.outingEvent?.event?.eventDate
                )
                
                // Expenses Section
                OutingExpensesSection(
                    users: users,
                    activities: getActivities(),
                    totalBudget: outing.totalExpense,
                    yourShare: outing.due,
                    onAddExpense: { showAddExpense = true }
                )
                
                
                // Owes Section
                OutingOwesSection(
                    users: users,
                    participants: getParticipants(),
                    debts: (outing.debts as? Set<DebtEntity>)?.map { $0 } ?? [],
                    yourShare: outing.due
                )
                
                // Participants Section
                ParticipantsSection(
                    users: users,
                    activities: getActivities()
                )
            }
            .padding(.bottom, 100)
            
            Spacer()
        }
        .sheet(isPresented: $showAddExpense) {
            DrawerModal(isOpen: $showAddExpense){
                AddExpenseDrawer(outing: outing)
            }
        }
        .onAppear{
            extractUsers()
        }
        .background(Color.primaryBackground)
    }
    
    private func getActivities() -> [ActivityDTO] {
        guard let activitiesString = outing.activities,
              let data = activitiesString.data(using: .utf8) else {
            return []
        }
        
        do {
            let activities = try JSONDecoder().decode([ActivityDTO].self, from: data)
            return activities
        } catch {
            print("[OutingView] Error decoding activities:", error)
            return []
        }
    }
    
    private func getParticipants() -> [ParticipantDTO] {
        let activities = getActivities()
        var participantIds = Set<String>()
        
        activities.forEach { activity in
            if let paidById = activity.paidById {
                participantIds.insert(paidById)
            }
            activity.participants.forEach { participantIds.insert($0) }
        }
        
        let participants = participantIds.filter { !$0.isEmpty }.map { id in
            ParticipantDTO(
                id: id,
                name: id,
                email: "",
                phoneNumber: ""
            )
        }
        return participants
    }
    
    private func extractUsers() {
        // Get participants from OutingEntity only
        let outingParticipants = (try? JSONDecoder().decode([String].self, from: Data(outing.participants?.utf8 ?? "[]".utf8))) ?? []
        
        // Convert to UserDTO objects
        var extractedUsers: [UserDTO] = outingParticipants.compactMap { id in
            // Try to parse the string as JSON
            if let jsonData = id.data(using: .utf8),
               let userInfo = try? JSONDecoder().decode(UserInfo.self, from: jsonData) {
                guard let uuid = UUID(uuidString: userInfo.id) else {
                    print("[OutingView] Invalid UUID in JSON: \(userInfo.id)")
                    return nil
                }
                return UserDTO(
                    id: uuid,
                    name: userInfo.name,
                    email: userInfo.email,
                    phoneNumber: userInfo.phoneNumber
                )
            } else {
                // Fallback for simple UUID strings
                guard let uuid = UUID(uuidString: id) else {
                    print("[OutingView] Invalid UUID string: \(id)")
                    return nil
                }
                return UserDTO(
                    id: uuid,
                    name: id,
                    email: "",
                    phoneNumber: ""
                )
            }
        }
        
        if let currentUser = AuthCoreDataModel.shared.currentUser,
           !extractedUsers.contains(where: { $0.id == currentUser.id }) {
            extractedUsers.append(currentUser)
        }
        
        users = extractedUsers
        //print("[OutingView] Extracted Users:", users)
    }
    
    struct UserInfo: Codable {
        let id: String
        let name: String
        let email: String
        let phoneNumber: String
    }
    
    private func getActivitiesCount() -> Int {
        return getActivities().count
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "Time" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}


// Update preview structure
struct OutingView_Previews: PreviewProvider {
    static var previews: some View {
        let outing = createPreviewOuting()
        NavigationView {
            OutingView(outing: outing)
        }
    }
    
    private static func createPreviewOuting() -> OutingEntity {
        let context = PersistenceController.shared.container.viewContext
        let outing = OutingEntity(context: context)
        
        // Create Event Entity
        let event = OutingEventEntity(context: context)
        event.id = UUID()
        event.createdAt = Date()
        event.updatedAt = Date()
        event.tickets = "2" // Example number of tickets
        
        // Create the associated EventEntity
        let eventDetails = EventEntity(context: context)
        eventDetails.id = UUID()
        eventDetails.title = "Wayo Live Concert"
        eventDetails.desc = "Live music concert at Nelum Pokuna"
        eventDetails.eventDate = Date()
        eventDetails.locationName = "Nelum Pokuna"
        
        // Link the event entities
        event.event = eventDetails
        
        // Sample data
        outing.id = UUID(uuidString: "b2c59db1-07f3-4470-9d68-5a25f5f60bff")
        outing.title = "Wayo Live Concert"
        outing.desc = "Concert at Nelum Pokuna"
        outing.totalExpense = 950.00
        outing.due = 316.67
        outing.outingEvent = event
        
        // Mock activities
        let activitiesJSON = """
        [
            {
                "id": "\(UUID())",
                "title": "Concert Tickets",
                "description": "Entry tickets",
                "amount": "450.00",
                "paidById": "1",
                "participants": ["J", "M"],
                "references": [],
                "createdAt": "\(ISO8601DateFormatter().string(from: Date()))",
                "updatedAt": "\(ISO8601DateFormatter().string(from: Date()))"
            },
            {
                "id": "\(UUID())",
                "title": "Taxi Fare",
                "description": "Transportation",
                "amount": "300.00",
                "paidById": "2",
                "participants": ["J", "M"],
                "references": [],
                "createdAt": "\(ISO8601DateFormatter().string(from: Date()))",
                "updatedAt": "\(ISO8601DateFormatter().string(from: Date()))"
            }
        ]
        """
        
        outing.activities = activitiesJSON
        
        return outing
    }
}
