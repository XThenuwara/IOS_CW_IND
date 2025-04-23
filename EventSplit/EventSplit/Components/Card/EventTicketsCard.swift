//
//  EventTicketsCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import SwiftUI

struct EventTicketsCard: View {
    let ticket: PurchasedTicketsWithEventDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Event Info Header
            HStack {
                VStack(alignment: .leading) {
                    Text(ticket.event.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text(formatDate(ticket.event.eventDate ?? ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                StatusBadge(text: ticket.status)
            }
            
            Divider()
            
            // Ticket Details
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Ticket #\(String(ticket.id.uuidString.prefix(6)).uppercased())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Qty: \(ticket.quantity)")
                        .font(.subheadline)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Unit Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("LKR \(String(format: "%.2f", Double(ticket.unitPrice) ?? 0.0))")
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("LKR \(String(format: "%.2f", Double(ticket.totalAmount) ?? 0.0))")
                            .font(.subheadline)
                            .bold()
                    }
                }
            }
            
            Divider()
            
            // Location Info
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                Text(ticket.event.locationName ?? "Location not specified")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Purchase Info
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("Purchased on \(formatDate(ticket.createdAt))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            ZStack {
                Color(.highLightBackground)
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let triangleWidth: CGFloat = 10
                        let triangleHeight: CGFloat = 6
                        let triangleCount = Int(width / triangleWidth)
                        
                        for i in 0...triangleCount {
                            let xOffset = CGFloat(i) * triangleWidth
                            path.move(to: CGPoint(x: xOffset, y: height))
                            path.addLine(to: CGPoint(x: xOffset + triangleWidth/2, y: height - triangleHeight))
                            path.addLine(to: CGPoint(x: xOffset + triangleWidth, y: height))
                        }
                    }
                    .stroke(Color.primaryBackground, lineWidth: 1)
                }
            }
        )
        .cornerRadius(12)
        .withShadow()
        .withBorder()
    }
    
    private func formatDate(_ dateString: String) -> String {
        guard let date = DateUtils.shared.parseISO8601Date(dateString) else {
            return dateString
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    let sampleTicket = PurchasedTicketsWithEventDTO(
        id: UUID(),
        eventId: UUID(),
        outingId: UUID(),
        userId: UUID(),
        ticketType: "VIP",
        quantity: 2,
        unitPrice: "5000.00",
        totalAmount: "10000.00",
        status: "completed",
        paymentMethod: "CARD",
        paymentReference: "DEMO-123",
        createdAt: "2024-03-25T10:00:00Z",
        updatedAt: "2024-03-25T10:00:00Z",
        event: EventDTO(
            id: UUID(),
            title: "Sample Event",
            description: "Sample Description",
            eventType: "MUSICAL",
            locationName: "Sample Venue",
            locationAddress: "123 Sample St",
            locationLongitudeLatitude: nil,
            eventDate: "2024-04-01T18:00:00Z",
            organizerName: nil,
            organizerPhone: nil,
            organizerEmail: nil,
            amenities: nil,
            requirements: nil,
            weatherCondition: nil,
            capacity: 100,
            sold: 50,
            ticketTypes: nil,
            createdAt: "2024-03-25T10:00:00Z",
            updatedAt: "2024-03-25T10:00:00Z"
        )
    )
    
    return EventTicketsCard(ticket: sampleTicket)
        .padding()
}
