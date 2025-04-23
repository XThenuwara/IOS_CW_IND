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
    let purchasedTickets: [PurchasedTicketsDTO]
    let onPaymentSuccessful: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Tickets")
                .font(.headline)
            
            if purchasedTickets.isEmpty {
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
            onPaymentSuccessful()
        }
    }

}