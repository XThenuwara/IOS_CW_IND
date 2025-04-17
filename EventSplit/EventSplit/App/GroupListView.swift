//
//  GroupView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-29.
//
import SwiftUI

struct GroupListView: View {
    @State private var showCreateGroup = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Groups")
                            .font(.system(size: 28, weight: .bold))
                        Text("Create groups to organize your events")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                
                Spacer()
                
                Button(action: { showCreateGroup = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("New")
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.secondaryBackground)
                    .foregroundColor(.primaryBackground)
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    GroupCard(
                        name: "Weekend Squad",
                        description: "For weekend adventures and trips",
                        memberCount: 6,
                        memberInitials: ["J", "J", "M"],
                        timeAgo: "2 days ago"
                    )
                    
                    GroupCard(
                        name: "Lunch Bunch",
                        description: "Office lunch group",
                        memberCount: 4,
                        memberInitials: ["J", "J"],
                        timeAgo: "5 hours ago"
                    )
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showCreateGroup) {
            CreateGroupDrawer()
        }
    }
}

#Preview {
    GroupListView()
        .preferredColorScheme(.light)
}
