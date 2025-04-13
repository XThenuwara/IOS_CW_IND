//
//  ParticipantChip.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-13.
//
import SwiftUI

struct ParticipantChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(String(name.prefix(1)))
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.blue))
                
                Text(name)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        ParticipantChip(
            name: "John Doe",
            isSelected: true,
            action: {}
        )
        ParticipantChip(
            name: "Jane Smith",
            isSelected: false,
            action: {}
        )
    }
    .padding()
}