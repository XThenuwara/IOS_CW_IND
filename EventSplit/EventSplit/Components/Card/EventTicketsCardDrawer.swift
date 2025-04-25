//
//  EventTicketsCardDrawer.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-25.
//
import SwiftUI
import CoreImage.CIFilterBuiltins

struct TicketTypeInfo: Codable {
    let ticketType: String
    let quantity: Int
}


struct EventTicketsCardDrawer: View {
    let ticket: PurchasedTicketsWithEventDTO
    @State private var showQRCode = false

    private var decodedTicketTypes: [TicketTypeInfo] {
        guard let ticketTypeData = ticket.ticketType.data(using: .utf8) else {
            return []
        }
        
        do {
            let ticketTypes = try JSONDecoder().decode([TicketTypeInfo].self, from: ticketTypeData)
            return ticketTypes
        } catch {
            return []
        }
    }
    
    
    private func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        let data = string.data(using: .utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                eventInfoSection
                ticketDetailsSection
                purchaseInfoSection
            }
            .padding()
            .padding(.bottom, 24)
            .background(Color.primaryBackground)
        }
    }
    
    // Header Section
    private var headerSection: some View {
        HStack {
            Text("Ticket Details")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // Event Info Section
    private var eventInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ticket.event.title)
                .font(.headline)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(formatDate(ticket.event.eventDate ?? ""))
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.secondary)
                Text(ticket.event.locationName ?? "Location not specified")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.highLightBackground)
        .cornerRadius(12)
        .withShadow()
    }
    
    // Single Ticket View
    private func singleTicketView(index: Int) -> some View {
        VStack(spacing: 16) {
            ticketHeaderView(index: index)
            ticketInfoGridView
            ticketQRCodeView(index: index)
            ticketAdditionalInfoView
        }
        .padding()
        .background(Color.highLightBackground)
        .cornerRadius(12)
        .withShadow()
    }

    private func ticketHeaderView(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if !decodedTicketTypes.isEmpty {
                    Text("\(decodedTicketTypes[0].ticketType) Ticket")
                        .font(.headline)
                } else {
                    Text("Ticket")
                        .font(.headline)
                }
                Spacer()
                Text("#\(String(format: "%03d", index + 1))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var ticketInfoGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            TicketInfoItem(title: "Event Date", value: formatDate(ticket.event.eventDate ?? ""))
            TicketInfoItem(title: "Event Time", value: formatTime(ticket.event.eventDate ?? ""))
            TicketInfoItem(title: "Ticket Type", value: decodedTicketTypes.isEmpty ? "Unknown" : decodedTicketTypes[0].ticketType)
            TicketInfoItem(title: "Ticket ID", value: String(ticket.id.uuidString.prefix(8)).uppercased())
        }
    }
    
    private func ticketQRCodeView(index: Int) -> some View {
        VStack(spacing: 8) {
            let ticketId = "\(ticket.id.uuidString)-\(index + 1)"
            Image(uiImage: generateQRCode(from: ticketId))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(16)
                .background(Color.white)
                .cornerRadius(8)
            
            Text(ticketId)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            
            Text("Scan to verify ticket")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var ticketAdditionalInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ticket Information")
                .font(.subheadline)
                .fontWeight(.medium)
            
            if !decodedTicketTypes.isEmpty {
                Text("• Ticket Type: \(decodedTicketTypes[0].ticketType)")
                Text("• Quantity: \(decodedTicketTypes[0].quantity)")
            }
            Text("• Please arrive at least 30 minutes before the event")
            Text("• Bring a valid ID for verification")
            Text("• This ticket is non-transferable")
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // Ticket Details Section
    private var ticketDetailsSection: some View {
        VStack(spacing: 16) {
            ForEach(0..<ticket.quantity, id: \.self) { index in
                singleTicketView(index: index)
            }
        }
    }
    
    // Purchase Info Section
    private var purchaseInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            purchaseHeader
            Divider()
            purchasePriceDetails
            Divider()
            purchaseDate
        }
        .padding()
        .background(Color.highLightBackground)
        .cornerRadius(12)
        .withShadow()
    }
    
    // Helper Views
    private var purchaseHeader: some View {
        HStack {
            Text("Purchase Details")
                .font(.headline)
            Spacer()
            StatusBadge(text: ticket.status)
        }
    }
    
    private var purchasePriceDetails: some View {
        Group {
            HStack {
                Text("Unit Price")
                Spacer()
                Text("LKR \(String(format: "%.2f", Double(ticket.unitPrice) ?? 0.0))")
            }
            
            HStack {
                Text("Quantity")
                Spacer()
                Text("\(ticket.quantity)")
            }
            
            HStack {
                Text("Total Amount")
                    .fontWeight(.semibold)
                Spacer()
                Text("LKR \(String(format: "%.2f", Double(ticket.totalAmount) ?? 0.0))")
                    .fontWeight(.semibold)
            }
        }
    }
    
    private var purchaseDate: some View {
        Text("Purchased on \(formatDate(ticket.createdAt))")
            .font(.caption)
            .foregroundColor(.secondary)
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

    private func formatTime(_ dateString: String) -> String {
        guard let date = DateUtils.shared.parseISO8601Date(dateString) else {
            return "Any Time"
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}
}


struct TicketInfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

