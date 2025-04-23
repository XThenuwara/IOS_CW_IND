//
//  DrawerModal.swift
//  camp-nav-ios-g-cw
//
//  Created by Yasas Hansaka Thenuwara on 2025-02-26.
//
import SwiftUI

struct DrawerModal<Content: View>: View {
    @Binding var isOpen: Bool
    let content: Content
    
    init(isOpen: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isOpen = isOpen
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drawer Handle
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 150, height: 15)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding()
                Spacer()
            }
            .onTapGesture {
                withAnimation {
                    isOpen.toggle()
                }
            }
            
            
            // Drawer Content
            content
                .frame(maxWidth: .infinity)
                .background(Color.primaryBackground)
                .cornerRadius(20)
                
        }
        .background(.primaryBackground)
        .transition(.move(edge: .bottom))
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    DrawerModal(isOpen: .constant(true)) {
        Text("Hello, World!")
    }
}
