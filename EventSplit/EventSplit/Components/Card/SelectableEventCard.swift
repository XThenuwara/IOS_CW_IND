//
//  SelectableEventCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-28.
//
import SwiftUI

struct SelectableEventCard: View {
    let event: EventEntity
    let isSelected: Bool
    let onSelect: () -> Void
    @StateObject private var locationManager = LocationManager()
    
    var distanceText: String {
        if let distance = locationManager.calculateDistance(to: event.locationGPS) {
            return String(format: "%.1f km away", distance)
        }
        return "Distance unknown"
    }
    
    var body: some View {
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
                            
                            HStack {
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
                    
                    Button(action: onSelect) {
                        HStack(spacing: 8) {
                            Text(isSelected ? "Selected" : "Select")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        }
                        .foregroundColor(isSelected ? .white : .blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
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
        }
        .padding(8)
        .background(
            isSelected ? Color.blue.opacity(0.05) : Color(UIColor.systemBackground)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
