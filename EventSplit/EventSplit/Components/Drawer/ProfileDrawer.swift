import SwiftUI

struct ProfileDrawer: View {
    var body: some View {
        VStack(spacing: 24) {
            // Profile Header
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                
                VStack(spacing: 4) {
                    Text("John Doe")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("john.doe@example.com")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical)
            
            // Menu Items
            VStack(spacing: 0) {
                DrawerMenuItem(icon: "person", title: "Profile")
                DrawerMenuItem(icon: "gear", title: "Settings")
                DrawerMenuItem(icon: "bell", title: "Notifications")
                DrawerMenuItem(icon: "questionmark.circle", title: "Help")
                DrawerMenuItem(icon: "arrow.right.square", title: "Logout", action: {
                    AuthCoreDataModel.shared.logout { success in
                        if success {
                            
                        }
                    }
                })
                .foregroundColor(.red)
            }
            .background(Color.white)
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
    }
}

struct DrawerMenuItem: View {
    let icon: String
    let title: String
    var action: (() -> Void)?
    
    var body: some View {
        Button(action: action ?? {}) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    ProfileDrawer()
}
