//
//  EventTicketDrawer.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//

import SwiftUI

struct EventTicketDrawer: View {
    let event: EventEntity
    let outingId: UUID?
    let onSuccess: () -> Void
    private var eventService = EventService(coreDataModel: EventCoreDataModel())
    @State private var tickets: [PurchasedTicketsWithEventDTO] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @Binding var isOpen: Bool
    
    init(event: EventEntity, isOpen: Binding<Bool>, outingId: UUID? = nil, onSuccess: @escaping () -> Void) {
        self.onSuccess = onSuccess
        self.event = event
        self._isOpen = isOpen
        self.outingId = outingId
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Event Tickets")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        isOpen = false
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 8)
                

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                } else if tickets.isEmpty {
                    Text("No tickets purchased yet")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                } else {
                    VStack(spacing: 16) {
                        ForEach(tickets, id: \.id) { ticket in
                            EventTicketsCard(ticket: ticket)
                        }
                    }
                }
                
                TicketsSection(
                    event: event,
                    outingId: outingId,
                    showGroupOutingSection: false,
                    onPaymentSuccessful: {
                        withAnimation {
                            fetchTickets()
                            onSuccess()
                        }
                    }
                )
            }
            .padding()
            .background(Color.primaryBackground)
        }
        .onAppear {
            withAnimation {
                fetchTickets()
            }
        }
    }
    
    private func fetchTickets() {
        isLoading = true
        errorMessage = nil
        
        guard let outingId = outingId else {
            isLoading = false
            errorMessage = "Invalid outing ID"
            return
        }
        
        eventService.getAllPurchasedTickets { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let allTickets):
                    self.tickets = allTickets.filter { $0.outingId == outingId }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// Preview Provider
struct EventTicketDrawer_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let event = EventEntity(context: context)
        
        // Setup mock event data
        event.id = UUID()
        event.title = "Wayo Live Concert"
        event.locationName = "Nelum Pokuna"
        event.eventDate = Date()
        
        // Mock tickets
        let mockTickets = [
            PurchasedTicketsWithEventDTO(
                id: UUID(),
                eventId: event.id!,
                outingId: UUID(),
                userId: UUID(),
                ticketType: "VIP",
                quantity: 2,
                unitPrice: "2500.00",
                totalAmount: "5000.00",
                status: "Confirmed",
                paymentMethod: "CARD",
                paymentReference: "REF123456",
                createdAt: Date().ISO8601Format(),
                updatedAt: Date().ISO8601Format(),
                event: EventDTO(
                    id: event.id!,
                    title: event.title!,
                    description: "Live Concert",
                    eventType: "musical",
                    locationName: event.locationName!,
                    locationAddress: "Colombo 07",
                    locationLongitudeLatitude: "6.9271,79.8612",
                    eventDate: Date().ISO8601Format(),
                    organizerName: "Event Organizers Ltd",
                    organizerPhone: "+94771234567",
                    organizerEmail: "info@organizers.com",
                    amenities: ["Parking", "Food Court"],
                    requirements: ["Valid ID"],
                    weatherCondition: "Clear",
                    capacity: 1000,
                    sold: 500,
                    ticketTypes: [],
                    createdAt: Date().ISO8601Format(),
                    updatedAt: Date().ISO8601Format()
                )
            )
        ]
        
        return DrawerModal(isOpen: .constant(true)) {
            EventTicketDrawer(
                event: event,
                isOpen: .constant(true),
                outingId: UUID(),
                onSuccess: {}
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
