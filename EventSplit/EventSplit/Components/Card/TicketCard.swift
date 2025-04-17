//
//  TicketCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import SwiftUI

struct TicketCard: View {
    let ticket: PurchasedTicketsDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ticket #\(String(ticket.id.uuidString.prefix(6)).uppercased())")
                    .font(.headline)
                Spacer()
                Text(ticket.status.capitalized)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Quantity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(ticket.quantity)")
                        .font(.body)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Total Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("LKR \(String(format: "%.2f", Double(ticket.totalAmount) ?? 0.0))")
                        .font(.body)
                }
            }
            
            Text("Purchased on \(formatDate(ticket.createdAt))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var statusColor: Color {
        switch ticket.status.lowercased() {
        case "completed":
            return .green
        case "pending":
            return .orange
        default:
            return .gray
        }
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