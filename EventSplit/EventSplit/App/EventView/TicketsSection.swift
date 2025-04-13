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
    @State private var selectedTicket: TicketDTO?
    
    private var tickets: [TicketDTO] {
        if let ticketData = event.ticketTypes?.data(using: .utf8) {
            do {
                let tickets = try JSONDecoder().decode([TicketDTO].self, from: ticketData)
                return tickets.map { ticket in
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
        return []
    }
    
    private var enumeratedTickets: [(index: Int, ticket: TicketDTO)] {
        tickets.enumerated().map { (index: Int, ticket: TicketDTO) in
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
                            Text("$\(String(format: "%.2f", ticket.price))")
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
                            }
                            .font(.caption)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.primary)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    
                    if index < tickets.count - 1 {
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
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "person.3")
                        Text("Create Group Outing")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .sheet(isPresented: $showPaymentView) {
             PaymentView(event: event)
        }
    }
}
