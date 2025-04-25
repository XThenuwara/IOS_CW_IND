//
//  Navbar.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-20.
//
import SwiftUI

struct Navbar: View {
    @Binding var selectedTab: Int            
    @State private var showProfileSheet = false
    @State private var showNotificationsSheet = false
    @State private var showSearchSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Logo and App Name
            HStack(spacing: 8) {
                Logo(color: .secondaryBackground)
                   .frame(width: 32, height: 32)
                Text("EventSplit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondaryBackground)
            }
            
            Spacer()
            
            // Search and Menu buttons
            HStack(spacing: 16) {
      
                Button(action: {
                    withAnimation {
                        selectedTab = 1  
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                }
                
                Button(action: {
                    showNotificationsSheet.toggle()
                }) {
                    Image(systemName: "bell")
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                }
                
                Button(action: {
                    showProfileSheet.toggle()
                }) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.highLightBackground)
        .cornerRadius(100)
        .shadow(color: Color.gray.opacity(0.3), radius: 2)
        .padding(.horizontal)
        .padding(.top, 8)
        .sheet(isPresented: $showProfileSheet) {
            DrawerModal(isOpen: $showProfileSheet) {
                ProfileDrawer()
            }
        }
        .sheet(isPresented: $showNotificationsSheet) {
            DrawerModal(isOpen: $showNotificationsSheet) {
                NotificationDrawer()
            }.presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showSearchSheet) {
            Text("Search")
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    Navbar(selectedTab: .constant(0))
}
