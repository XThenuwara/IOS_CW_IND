import SwiftUI

struct OutingEventCard: View {
    let eventData: EventEntity
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(eventData.title ?? "Event Title")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Confirmed")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.2))
                    .foregroundColor(.yellow)
                    .clipShape(Capsule())
            }
            
            VStack(spacing: 12) {
                EventInfoRow(icon: "mappin", text: eventData.locationName ?? "Location")
                EventInfoRow(icon: "calendar", text: formatDate(eventData.eventDate))
                EventInfoRow(icon: "clock", text: formatTime(eventData.eventDate))
                
                HStack {
                    EventInfoRow(icon: "ticket", text: "3 Tickets")
                    Spacer()
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Image(systemName: "eye")
                                .font(.system(size: 14))
                            Text("View Tickets")
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.secondary.opacity(0.1))
                        .foregroundColor(.primary)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2))
        )
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "Time" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
