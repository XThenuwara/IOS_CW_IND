import SwiftUI

struct Logo: View {
    var size: CGFloat = 24
    var color: Color = .black
    
    var body: some View {
        Image("Logo")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(color)
            .frame(width: size, height: size)
    }
}

#Preview {
    VStack {
        Logo(size: 64, color: .secondaryBackground)
        Logo(size: 64, color: .black)
    }
    .padding()
}
