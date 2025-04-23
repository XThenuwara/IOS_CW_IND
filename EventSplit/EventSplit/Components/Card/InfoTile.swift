//
//  InfoTile.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

enum InfoTileType {
    case error
    case success
    case warning
    
    var backgroundColor: Color {
        switch self {
        case .error: return .red.opacity(0.1)
        case .success: return .green.opacity(0.1)
        case .warning: return .orange.opacity(0.1)
        }
    }
    
    var iconName: String {
        switch self {
        case .error: return "xmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .error: return .red
        case .success: return .green
        case .warning: return .orange
        }
    }
}

struct InfoTile: View {
    let message: String
    @Binding var isVisible: Bool
    var type: InfoTileType = .error
    
    var body: some View {
        if isVisible {
            HStack(spacing: 12) {
                Image(systemName: type.iconName)
                    .foregroundColor(type.iconColor)
                
                Text(message)
                    .font(.subheadline)
                
                Spacer()
                
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(type.backgroundColor)
            .cornerRadius(8)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        InfoTile(message: "This is an error message", isVisible: .constant(true), type: .error)
        InfoTile(message: "This is a success message", isVisible: .constant(true), type: .success)
        InfoTile(message: "This is a warning message", isVisible: .constant(true), type: .warning)
    }
}