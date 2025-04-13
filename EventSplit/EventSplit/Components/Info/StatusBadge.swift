//
//  StatusBadge.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-24.
//
import SwiftUI

struct StatusBadge: View {
    let status: OutingStatus
    
    var backgroundColor: Color {
        switch status {
        case .draft: return Color.gray.opacity(0.2)
        case .inProgress: return Color.yellow.opacity(0.2)
        case .unsettled: return Color.orange.opacity(0.2)
        case .settled: return Color.green.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch status {
        case .draft: return .gray
        case .inProgress: return .yellow
        case .unsettled: return .orange
        case .settled: return .green
        }
    }
    
    var displayText: String {
        switch status {
        case .draft : return "Draft"
        case .inProgress: return "In Progress"
        case .unsettled: return "Unsettled"
        case .settled: return "Settled"
        }
    }
    
    var body: some View {
        Text(displayText)
            .font(.system(size: 12, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
    }
}