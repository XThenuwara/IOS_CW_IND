//
//  EventRequirementsSection.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

struct EventRequirementsSection: View {
    let requirements: [String]
    let weatherCondition: String
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Requirements")
                    .font(.headline)
                
                ForEach(requirements, id: \.self) { requirement in
                    HStack(spacing: 4) {
                        Circle()
                            .frame(width: 4, height: 4)
                        Text(requirement)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Weather")
                    .font(.headline)
                
                Text(weatherCondition)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}