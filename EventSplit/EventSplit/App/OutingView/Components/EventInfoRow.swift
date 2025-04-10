import SwiftUI

struct EventInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(width: 16, height: 16, alignment: .leading) 
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading) 
        }
    }
}


#Preview {
    EventInfoRow(icon: "L", text: "Location")
}
