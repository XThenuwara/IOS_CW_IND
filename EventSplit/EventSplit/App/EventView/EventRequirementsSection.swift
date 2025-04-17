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
                    .foregroundColor(.secondaryBackground)
                
                ForEach(requirements, id: \.self) { requirement in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.secondaryBackground)
                            .frame(width: 4, height: 4)
                        Text(requirement)
                            .font(.caption)
                            .foregroundColor(.secondaryBackground)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Weather")
                    .font(.headline)
                    .foregroundColor(.secondaryBackground)
                
                Text(weatherCondition)
                    .font(.caption)
                    .foregroundColor(.secondaryBackground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(.primaryBackground)
        .cornerRadius(12)
    }
}