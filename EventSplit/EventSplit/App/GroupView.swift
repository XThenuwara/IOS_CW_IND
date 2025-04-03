import SwiftUI

struct GroupView: View {
    @State private var showCreateGroup = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Groups")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showCreateGroup = true }) {
                    Text("Create Group")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .foregroundColor(.blue)
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
    GroupView()
        .preferredColorScheme(.light)
}