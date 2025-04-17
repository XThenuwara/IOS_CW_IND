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
                Color.gray.opacity(0.4)
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)  
                    .blur(radius: 10)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondaryBackground)
                        
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.secondaryBackground)
                    }
                    
                    Button(action: {
                        withAnimation {
                            onDismiss()
                        }
                    }) {
                        Text("Dismiss")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primaryBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(.secondaryBackground)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .background(.primaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.secondaryBackground.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .transition(.move(edge: .top).combined(with: .opacity))
                .withShadow()
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

 
