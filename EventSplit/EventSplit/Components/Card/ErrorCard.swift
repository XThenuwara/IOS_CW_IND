//
//  ErrorCard.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-22.
//
import SwiftUI

struct ErrorCard: View {
    let message: String
    let isVisible: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            if isVisible {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.red)
                        .padding(.top)
                    
                    Text(message)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    Button(action: {
                        withAnimation {
                            onDismiss()
                        }
                    }) {
                        Text("OK")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 40)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(), value: isVisible)
    }
}

struct ErrorCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorCard(
                message: "An unexpected error occurred. Please try again later.",
                isVisible: true,
                onDismiss: { print("Dismiss button tapped") }
            )
            .previewDisplayName("Default")
            
            ErrorCard(
                message: "Network connection failed. Please check your internet connection and try again.",
                isVisible: true,
                onDismiss: { print("Dismiss button tapped") }
            )
            .previewDisplayName("Long Message")
            .previewLayout(.sizeThatFits)
        }
    }
}

 
