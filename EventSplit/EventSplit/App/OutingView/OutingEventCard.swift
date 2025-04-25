//
//  OutingEventCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-29.
//
import SwiftUI

struct OutingEventCard: View {
    @State private var showTicketDrawer = false
    let outing: OutingDTO
    let eventData: OutingEventDTO
    let onSuccess: () -> Void
    @State private var tickets: [PurchasedTicketsWithEventDTO] = []
    @State private var isLoading = true
    private let eventService = EventService(coreDataModel: EventCoreDataModel())
    private let eventCoreDataModel = EventCoreDataModel()
    
    var body: some View {
        cardContent
            .padding()
            .background(.highLightBackground)
            .cornerRadius(16)
            .withShadow()
            .withBorder()
            .padding(.horizontal)
            .sheet(isPresented: $showTicketDrawer) {
                ticketDrawerContent
            }
            .onAppear {
                fetchTickets()
            }
    }
    
    // MARK: - View Components
    private var cardContent: some View {
        VStack(spacing: 16) {
            headerSection
            detailsSection
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text(eventData.event.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            let tickets = Int(tickets.count) ?? 0
            StatusBadge(
                text: tickets > 0 ? "Confirmed" : "Not Confirmed",
                statusColor: tickets > 0 ? .green : .gray
            )
        }
    }
    
    private var detailsSection: some View {
        VStack(spacing: 12) {
            EventInfoRow(icon: "mappin", text: eventData.event.locationName ?? "Location not available")
            EventInfoRow(icon: "calendar", text: formatDate(DateUtils.shared.parseISO8601Date(eventData.event.eventDate)))
            EventInfoRow(icon: "clock", text: formatTime(DateUtils.shared.parseISO8601Date(eventData.event.eventDate)))
            EventInfoRow(icon: "ticket", text: "\(tickets.count) Tickets")
            ticketsRow
        }
    }
    
    private var ticketsRow: some View {
        HStack {
            Spacer()
            viewTicketsButton
        }
    }
    
    private var viewTicketsButton: some View {
        Button(action: { showTicketDrawer = true }) {
            Text("View Tickets")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.secondary.opacity(0.1))
                .foregroundColor(.primary)
                .clipShape(Capsule())
        }
    }
    
    private var ticketDrawerContent: some View {
        DrawerModal(isOpen: $showTicketDrawer) {
            if let eventEntity = eventCoreDataModel.getEvent(id: eventData.event.id) {
                EventTicketDrawer(
                    event: eventEntity,
                    isOpen: $showTicketDrawer,
                    outingId: outing.id,
                    onSuccess: {
                        fetchTickets()
                        onSuccess()
                    }
                )
            }
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Date not available" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "Time not available" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func fetchTickets() {
        isLoading = true
        
        eventService.getAllPurchasedTickets { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let allTickets):
                    self.tickets = allTickets.filter { $0.outingId == outing.id }
                case .failure(let error):
                    print("Error fetching tickets:", error)
                    self.tickets = []
                }
            }
        }
    }
}
