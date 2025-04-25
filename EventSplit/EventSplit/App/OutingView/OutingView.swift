//
//  OutingView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-25.
//
import SwiftUI

struct OutingView: View {
    private let eventService = EventService(coreDataModel: EventCoreDataModel())
    private let outingService = OutingService(coreDataModel: OutingCoreDataModel())
    @State private var showAddExpense = false
    @State private var users: [UserDTO] = []
    @State private var outing: OutingDTO
    @State private var isRefreshing = false
    
    init(outing: OutingDTO) {
        self.outing = outing
        _outing = State(initialValue: outing)
    }
    
    var body: some View {
        ScrollView {
            outingContent
                .overlay {
                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.2))
                    }
                }
        }
        .sheet(isPresented: $showAddExpense) {
            DrawerModal(isOpen: $showAddExpense){
                AddExpenseDrawer(outing: outing, onSuccess: {
                    withAnimation {
                        refreshOuting()
                        showAddExpense = false
                    }
                })
            }
        }
        .onAppear{
            extractUsers()
            refreshOuting()
        }
        .background(Color.primaryBackground)
    }
    
    private var outingContent: some View {
        VStack(spacing: 20) {
            outingHeader
            if let event = outing.outingEvents?.first {
                OutingEventCard(
                    outing: outing,
                    eventData: event,
                    onSuccess: {
                        withAnimation {
                            refreshOuting()
                        }
                    }
                )
            }
            outingCalendarSection
            outingExpensesSection
            outingOwesSection
            outingParticipantsSection
            
            Spacer()
        }
        .padding(.bottom, 100)
    }
    
    private var outingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(outing.title)
                    .font(.system(size: 28, weight: .bold))
                Text("Discover events happening in your area")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // Button(action: refreshOuting) {
                //     Image(systemName: "arrow.clockwise")
                //         .font(.system(size: 14))
                //         .padding(.all, 8)
                //         .background(.primaryBackground)
                //         .foregroundColor(.secondaryBackground)
                //         .clipShape(Circle())
                //         .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                //         .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                // }
                
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
        }
        .padding()
    }
    
    private var outingCalendarSection: some View {
        OutingCalendarCheck(
            title: outing.title,
            description: outing.description,
            startDate: ISO8601DateFormatter().date(from: outing.outingEvents?.first?.event.eventDate ?? "") ?? Date()
        )
    }
    
    private var outingExpensesSection: some View {
        OutingExpensesSection(
            users: users,
            activities: outing.activities ?? [],
            totalBudget: calculateTotalBudget(),
            yourShare: calculateYourShare(),
            onAddExpense: { showAddExpense = true }
        )
    }
    
    private var outingOwesSection: some View {
        OutingOwesSection(
            users: users,
            participants: outing.participants,
            debts: outing.debts ?? [],
            yourShare: calculateYourShare()
        )
    }
    
    private var outingParticipantsSection: some View {
        ParticipantsSection(
            users: users,
            activities: outing.activities ?? [],
            outingId: outing.id.uuidString
        )
    }
    
    
    private func extractUsers() {
        var extractedUsers: [UserDTO] = []
        
        for participant in outing.participants {
            let userDTO = UserDTO(
                id: UUID(uuidString: participant.id) ?? UUID(),
                name: participant.name,
                email: participant.email ?? "",
                phoneNumber: participant.phoneNumber
            )
            extractedUsers.append(userDTO)
        }
        
        
        if let currentUser = AuthCoreDataModel.shared.currentUser,
           !extractedUsers.contains(where: { $0.id == currentUser.id }) {
            extractedUsers.append(currentUser)
        }
        
        users = extractedUsers
    }
    
    private func calculateYourShare() -> Double {
        let currentUserId = AuthCoreDataModel.shared.currentUser?.id
        if let debt = outing.debts?.first(where: { $0.fromUserId == currentUserId?.uuidString }) {
            return Double(debt.amount) ?? 0.0
        }
        return 0.0
    }

    private func calculateTotalBudget() -> Double {
        return (outing.activities ?? []).reduce(0.0) { total, activity in
            total + (Double(activity.amount) ?? 0.0)
        }
    }
    
    private func refreshOuting() {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            outingService.getOuting(outingId: outing.id.uuidString) { result in
                DispatchQueue.main.async {
                    isRefreshing = false
                    
                    switch result {
                    case .success(let outingDTO):
                        withAnimation {
                            self.outing = OutingDTO(
                                id: UUID(),
                                title: "",
                                description: "",
                                owner: UserDTO(id: UUID(), name: "", email: "", phoneNumber: ""),
                                participants: [],
                                activities: [],
                                outingEvents: [],
                                debts: [],
                                status: .draft,
                                createdAt: "",
                                updatedAt: ""
                            )
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    self.outing = outingDTO
                                    self.extractUsers()
                                }
                            }
                        }
                    case .failure(let error):
                        print("Failed to refresh outing:", error)
                    }
                }
            }
        }
    }
}

struct OutingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OutingView(outing: previewOuting)
        }
    }
    
    static var previewOuting: OutingDTO {
        OutingDTO(
            id: UUID(),
            title: "Preview Outing",
            description: "Preview description",
            owner: UserDTO(id: UUID(), name: "Owner", email: "owner@example.com", phoneNumber: "1234567890"),
            participants: [],
            activities: [],
            outingEvents: [],
            debts: [],
            status: .draft,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date())
        )
    }
}
