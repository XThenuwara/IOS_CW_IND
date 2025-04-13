//
//  EventCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-26.
//
import SwiftUI

struct EventCard: View {
    let event: EventEntity
    @StateObject private var locationManager = LocationManager()
    @State private var showEventDetails = false
    
    var distanceText: String {
        
        if let distance = locationManager.calculateDistance(to: event.locationGPS) {
            return String(format: "%.1f km away", distance)
        }
        return "Distance unknown"
    }
    
    var body: some View {
        Button(action: {
            showEventDetails = true
        }) {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Status
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title ?? "Unknown Title")
                                .font(.system(size: 20, weight: .semibold))
                                .padding(.bottom, 8)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle")
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.gray)
                                
                                HStack() {
                                    Text(event.locationName ?? "Unknown Venue")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                    Text(distanceText)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray.opacity(0.8))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Info row
                    HStack(spacing: 24) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                            if let date = event.eventDate {
                                Text(date, style: .date)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "person.2")
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                            Text("\(event.sold) joined")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(16)
                
                Divider()
                
                HStack {
                    HStack() {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                        Text("Available")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("\(event.capacity - event.sold)")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // TODO: Handle view details action
                    }) {
                        HStack(spacing: 4) {
                            Text("Join Event")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.all, 8)
                    .background(.primaryBackground)
                    .foregroundColor(.secondaryBackground)
                    .withBorder()
                    .withShadow()
                    .cornerRadius(200)
                
                }
                .padding(16)
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .withBorder()
            .withShadow()
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showEventDetails) {
            EventView(event: event)
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext

    let event = EventEntity(context: context)
    event.title = "Sample Event"
    event.locationName = "Sample Venue"
    event.locationGPS = "2.1km away"
    event.eventDate = Date()
    event.capacity = 100
    event.sold = 56
    
    return EventCard(event: event)
        .previewLayout(.sizeThatFits)
        .padding()
}

