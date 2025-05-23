//
//  EventView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct EventView: View {
    let event: EventEntity
    @State private var purchasedTickets: [PurchasedTicketsDTO] = []
    private let eventService = EventService(coreDataModel: EventCoreDataModel())
    @State private var error: Error?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 20) {
                    VStack(spacing: 0) {
                        // Event Image
                        ZStack(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(height: 200)
                            
                            Text(event.eventType ?? "Event")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(20)
                                .padding()
                        }
                        
                        VStack(spacing: 16) {
                            // Title and Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text(event.title ?? "")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(event.desc ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Location and Date
                            HStack(spacing: 12) {
                                // Location Card
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "mappin.circle")
                                        Text(event.locationName ?? "")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                    }
                                    Text(event.locationAddress ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.primaryBackground)
                                .cornerRadius(12)
                                
                                // Date Card
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text(formatDate(event.eventDate))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                    }
                                    Text(formatTime(event.eventDate))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.primaryBackground)
                                .cornerRadius(12)
                            }
                            
                            // Organizer Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Organizer")
                                    .font(.headline)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(event.organizerName ?? "")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack(spacing: 16) {
                                        Link(destination: URL(string: "tel:\(event.organizerPhone ?? "")")!) {
                                            HStack {
                                                Image(systemName: "phone")
                                                Text(event.organizerPhone ?? "")
                                            }
                                        }
                                        Link(destination: URL(string: "mailto:\(event.organizerEmail ?? "")")!) {
                                            HStack {
                                                Image(systemName: "envelope")
                                                Text("Email")
                                            }
                                        }
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.primaryBackground)
                            .cornerRadius(12)
                            
                            // Additional Information Sections
                            let amenities = event.amenities?.components(separatedBy: ",") ?? []
                            if !amenities.isEmpty {
                                EventAmenitiesSection(amenities: amenities)
                            }
                            
                            let requirements = event.requirements?.components(separatedBy: ",") ?? []
                            if !requirements.isEmpty {
                                EventRequirementsSection(
                                    requirements: requirements,
                                    weatherCondition: event.weatherCondition ?? "Not available"
                                )
                            }
                            
                            HStack {
                                HStack {
                                    Image(systemName: "person.3")
                                    Text("Capacity")
                                        .fontWeight(.medium)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("\(event.capacity - event.sold) tickets left")
                                        .fontWeight(.semibold)
                                    Text("out of \(event.capacity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(.primaryBackground)
                            .cornerRadius(12)
                            
                        }
                        .padding()
                    }
                    .background(Color.highLightBackground)
                    .cornerRadius(16)
                    .withShadow()
                    .withBorder()
                }
                
                PurchasedTicketsSection(event: event, purchasedTickets: purchasedTickets, onPaymentSuccessful: loadPurchasedTickets)
                
                
                TicketsSection(
                    event: event,
                    onPaymentSuccessful: loadPurchasedTickets
                )
            }
            .padding(.horizontal, 10)
        }
        .background(.primaryBackground)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "Time" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func loadPurchasedTickets() {
        guard let eventId = event.id else { return }
        
        eventService.getPurchasedTickets(eventId: eventId) { result in
            DispatchQueue.main.async {
                
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

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let event = EventEntity(context: context)
        
        // Basic Info
        event.id = UUID()
        event.title = "Wayo Live Concert"
        event.desc = "Join us for an unforgettable evening of live music featuring Wayo at Nelum Pokuna"
        event.eventType = "Concert"
        event.eventDate = Date()
        
        // Location
        event.locationName = "Nelum Pokuna"
        event.locationAddress = "Colombo 07, Sri Lanka"
        
        // Organizer
        event.organizerName = "Event Masters"
        event.organizerPhone = "+94771234567"
        event.organizerEmail = "contact@eventmasters.lk"
        
        // Capacity
        event.capacity = 1000
        event.sold = 750
        
        // Weather
        event.weatherCondition = "Clear skies, 28°C"
        
        // Amenities (JSON string)
        event.amenities = """
        [
            "VIP Seating",
            "Food Court",
            "Parking",
            "Security"
        ]
        """
        
        // Requirements (JSON string)
        event.requirements = """
        [
            "Valid ID",
            "Tickets",
            "Face Mask",
            "No Camera"
        ]
        """
        
        event.ticketTypes = """
        [
            {
                "id": "\(UUID().uuidString)",
                "name": "VIP",
                "price": 199.99,
                "totalQuantity": 100,
                "soldQuantity": 20
            },
            {
                "id": "\(UUID().uuidString)",
                "name": "Standard",
                "price": 99.99,
                "totalQuantity": 500,
                "soldQuantity": 100
            }
        ]
        """
        
        return EventView(event: event)
    }
}
