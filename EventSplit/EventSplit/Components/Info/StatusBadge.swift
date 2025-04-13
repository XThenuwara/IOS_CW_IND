//
//  StatusBadge.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-24.
//
import SwiftUI

enum StatusColor {
    case blue
    case green
    case yellow
    case red
    case gray
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .red: return .red
        case .gray: return .gray
        }
    }
    
    static func fromText(_ text: String) -> StatusColor {
        let lowercased = text.lowercased()
        
        switch lowercased {
        case "draft", "pending", "inactive", "disabled":
            return .gray
        case "active", "completed", "success", "approved", "settled":
            return .green
        case "warning", "in progress", "processing", "waiting":
            return .yellow
        case "error", "failed", "rejected", "cancelled", "blocked":
            return .red
        default:
            return .blue
        }
    }
}

struct StatusBadge: View {
    let text: String
    let statusColor: StatusColor
    
    init(text: String, statusColor: StatusColor? = nil) {
        self.text = text
        self.statusColor = statusColor ?? StatusColor.fromText(text)
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor.color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
