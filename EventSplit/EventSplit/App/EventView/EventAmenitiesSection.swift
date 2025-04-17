//
//  EventAmenitiesSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct EventAmenitiesSection: View {
    let amenities: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amenities")
                .font(.headline)
                .foregroundColor(.secondaryBackground)
            
            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], spacing: 8) {
                ForEach(amenities, id: \.self) { amenity in
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.secondaryBackground)
                        Text(amenity)
                            .font(.subheadline)
                            .foregroundColor(.secondaryBackground)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(.primaryBackground)
        .cornerRadius(12)
    }
}
