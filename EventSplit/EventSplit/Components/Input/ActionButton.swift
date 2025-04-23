//
//  ActionButton.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI

enum ActionButtonState {
    case `default`
    case loading
    case success
    case error
    
    var backgroundColor: Color {
        switch self {
        case .default: return .secondaryBackground
        case .loading: return .secondaryBackground.opacity(0.7)
        case .success: return .green
        case .error: return .red
        }
    }
    
    var icon: String? {
        switch self {
        case .default: return nil
        case .loading: return nil
        case .success: return "checkmark"
        case .error: return "xmark"
        }
    }
}

struct ActionButton: View {
    let title: String
    let action: () -> Void
    var state: ActionButtonState = .default
    var fullWidth: Bool = true
    
    var body: some View {
        Button(action: {
            if state != .loading {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if state == .loading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .primaryBackground))
                }
                
                if let iconName = state.icon {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(state == .success ? Color.green : Color.red)
                        .clipShape(Circle())
                }
                
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding()
            .background(.secondaryBackground)
            .foregroundColor(.primaryBackground)
            .cornerRadius(8)
            .animation(.easeInOut, value: state)
        }
        .disabled(state == .loading)
    }
}

#Preview {
    VStack(spacing: 20) {
        ActionButton(title: "Default Button", action: {})
        
        ActionButton(title: "Loading Button", action: {}, state: .loading)
        
        ActionButton(title: "Success Button", action: {}, state: .success)
        
        ActionButton(title: "Error Button", action: {}, state: .error)
        
        ActionButton(title: "Compact Button", action: {}, fullWidth: false)
    }
    .padding()
}