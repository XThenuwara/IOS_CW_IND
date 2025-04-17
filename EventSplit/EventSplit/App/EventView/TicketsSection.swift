//
//  TicketsSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct TicketsSection: View {
    let event: EventEntity
    @State private var showPaymentView = false
    @State private var showCreateOuting = false
    @State private var selectedTicket: TicketDTO = TicketDTO(
        id: UUID().uuidString,
        name: "",
        price: 5000.0,
        totalQuantity: 1,
        soldQuantity: 0
    )
    
    @State private var processedTickets: [TicketDTO] = []
    
    private func loadTickets() {
        if let ticketData = event.ticketTypes?.data(using: .utf8) {
            do {
                let tickets = try JSONDecoder().decode([TicketDTO].self, from: ticketData)
                processedTickets = tickets.map { ticket in
                    var mutableTicket = ticket
                    mutableTicket.id = UUID().uuidString
                    return mutableTicket
                }
            } catch {
                print("❌ TicketsSection JSON Decoding failed:", error)
            }
        } else {
            print("❌ TicketsSection Failed to convert string to Data")
        }
    }
    
    private var enumeratedTickets: [(index: Int, ticket: TicketDTO)] {
        processedTickets.enumerated().map { (index: Int, ticket: TicketDTO) in
            (index: index, ticket: ticket)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(enumeratedTickets, id: \.ticket.id) { index, ticket in
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(ticket.name) Ticket")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("LKR \(String(format: "%.2f", ticket.price))")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("\(ticket.available) available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            selectedTicket = ticket
                            showPaymentView = true
                        }) {
                            HStack {
                                Image(systemName: "ticket")
                                Text("Buy \(ticket.name)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.primary)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    
                    if index < processedTickets.count - 1 {
                        Divider()
                    }
                }
            }
            
            Divider()
            
            // Group Outing Section
            VStack(spacing: 8) {
                Text("Going with friends? Create a group outing to split expenses and manage your trip together!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    showCreateOuting = true
                }) {
                    HStack {
                        Image(systemName: "person.3")
                        Text("Create Group Outing")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.secondaryBackground)
                    .background(Color.primaryBackground)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .withShadow()
        .withBorder()
        .onAppear {
            loadTickets()
        }
        .sheet(isPresented: $showPaymentView) {
            DrawerModal(isOpen: $showPaymentView) {
                PaymentView(event: event, ticket: selectedTicket)
            }
        }
        .sheet(isPresented: $showCreateOuting) {
            DrawerModal(isOpen: $showCreateOuting) {
                CreateOutingDrawerWithEvent(preSelectedEvent: event)
            }
        }
    }
}
