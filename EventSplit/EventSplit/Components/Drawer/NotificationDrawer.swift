import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let time: Date
    let isRead: Bool
}

struct NotificationDrawer: View {
    @State private var notifications = [
        NotificationItem(
            title: "New Event Invitation",
            message: "John invited you to Beach Party",
            time: Date().addingTimeInterval(-3600),
            isRead: false
        ),
        NotificationItem(
            title: "Payment Reminder",
            message: "You have a pending payment for Movie Night",
            time: Date().addingTimeInterval(-7200),
            isRead: true
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Notifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // Mark all as read
                }) {
                    Text("Mark all as read")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Notifications List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(notifications) { notification in
                        NotificationCard(notification: notification)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

struct NotificationCard: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Unread indicator
            if !notification.isRead {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(notification.message)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                Text(notification.time, style: .relative)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(notification.isRead ? Color.gray.opacity(0.05) : Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    NotificationDrawer()
}