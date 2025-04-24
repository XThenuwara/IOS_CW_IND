//
//  OutingEventCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-29.
//
import SwiftUI

struct OutingEventCard: View {
    @State private var showTicketDrawer = false
    let outingEntity: OutingEntity
    let eventData: EventEntity
    let tickets: [PurchasedTicketsWithEventDTO] 
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(eventData.title ?? "Event Title")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                let tickets = Int(outingEntity.outingEvent?.tickets ?? "0") ?? 0
                StatusBadge(
                    text: tickets > 0 ? "Confirmed" : "Not Confirmed",
                    statusColor: tickets > 0 ? .green : .gray
                )
            }
            
            VStack(spacing: 12) {
                EventInfoRow(icon: "mappin", text: eventData.locationName ?? "Location")
                EventInfoRow(icon: "calendar", text: formatDate(eventData.eventDate))
                EventInfoRow(icon: "clock", text: formatTime(eventData.eventDate))
                
                HStack {
                    EventInfoRow(icon: "ticket", text: "\(tickets.count) Tickets")
                    Spacer()
                    
                    Button(action: {
                        showTicketDrawer = true
                    }) {
                        HStack(spacing: 4) {
                            Text("View")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(.highLightBackground)
        .cornerRadius(16)
        .withShadow()
        .withBorder()
        .padding(.horizontal)
        .sheet(isPresented: $showTicketDrawer) {
            DrawerModal(isOpen: $showTicketDrawer) {
                EventTicketDrawer(
                    event: eventData,
                    isOpen: $showTicketDrawer,
                    outingId: outingEntity.id
                )
            }
        }
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
