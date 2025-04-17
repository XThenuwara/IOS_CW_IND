//
//  PurchasedTicketsSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import SwiftUI

struct PurchasedTicketsSection: View {
    let event: EventEntity
    @State private var purchasedTickets: [PurchasedTicketsDTO] = []
    @State private var isLoading = false
    @State private var error: Error?
    
    private let eventService = EventService(coreDataModel: EventCoreDataModel())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Tickets")
                .font(.headline)
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let error = error {
                Text("Failed to load tickets: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else if purchasedTickets.isEmpty {
                Text("No tickets purchased yet")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(purchasedTickets, id: \.id) { ticket in
                            TicketCard(ticket: ticket)
                        }
                    }
                }
            }
        }
        .onAppear {
            loadPurchasedTickets()
        }
    }
    
    private func loadPurchasedTickets() {
        guard let eventId = event.id else { return }
        
        isLoading = true
        error = nil
        
        eventService.getPurchasedTickets(eventId: eventId) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let tickets):
                    self.purchasedTickets = tickets
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
}