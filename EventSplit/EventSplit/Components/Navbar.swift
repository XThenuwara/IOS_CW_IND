import SwiftUI

struct Navbar: View {
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
                    // TODO: Handle search
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                }
                
                Button(action: {
                    // TODO: Handle Notifications Drawer
                }) {
                    Image(systemName: "bell")
                        .foregroundColor(.primary)
                        .frame(width: 24, height: 24)
                }
                
                Button(action: {
                    // TODO: Handle Profile Drawer
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
        .background(Color.white)
        .cornerRadius(100)
        .shadow(color: Color.gray.opacity(0.3), radius: 2)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    Navbar()
}
