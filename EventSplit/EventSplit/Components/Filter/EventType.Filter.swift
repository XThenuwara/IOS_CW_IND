import SwiftUI

struct EventTypeFilter: View {
    @Binding var selectedType: EventTypeEnum?
    var onTypeSelected: () -> Void
    
    var body: some View {
        Menu {
            Button("All", action: { 
                selectedType = nil
                onTypeSelected()
            })
            Button("Musical", action: { 
                selectedType = .musical
                onTypeSelected()
            })
            Button("Sports", action: { 
                selectedType = .sports
                onTypeSelected()
            })
            Button("Food", action: { 
                selectedType = .food
                onTypeSelected()
            })
            Button("Art", action: { 
                selectedType = .art
                onTypeSelected()
            })
            Button("Theater", action: { 
                selectedType = .theater
                onTypeSelected()
            })
            Button("Movie", action: { 
                selectedType = .movie
                onTypeSelected()
            })
            Button("Conference", action: { 
                selectedType = .conference
                onTypeSelected()
            })
            Button("Other", action: { 
                selectedType = .other
                onTypeSelected()
            })
        } label: {
            HStack {
                Text(selectedType?.displayName ?? "Type")
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
            }
            .frame(width: 128, height: 20)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.05), radius: 2)
        }
    }
}

#Preview {
    EventTypeFilter(selectedType: .constant(.musical)) {
        print("Type selected")
    }
}