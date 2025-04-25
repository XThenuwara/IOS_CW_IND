//
//  GroupCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-02.
//
import SwiftUI

struct GroupCard: View {
    let name: String
    let description: String
    let memberCount: Int
    let memberInitials: [String]
    let timeAgo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.secondaryBackground)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .foregroundColor(.secondary)
                    Text("\(memberCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                // Member Initials
                HStack(spacing: -8) {
                    ForEach(memberInitials.prefix(3), id: \.self) { initial in
                        Text(initial)
                            .font(.caption)
                            .foregroundColor(.secondaryBackground)
                            .frame(width: 24, height: 24)
                            .background(Circle().fill(.primaryBackground))
                    }
                }
                
                Spacer()
                
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.highLightBackground)
        .cornerRadius(12)
    }
}

#Preview {
    GroupCard(
        name: "Weekend Squad",
        description: "For weekend adventures and trips",
        memberCount: 6,
        memberInitials: ["J", "J", "M"],
        timeAgo: "2 days ago"
    )
    .padding()
    .background(Color(.systemGray6))
}