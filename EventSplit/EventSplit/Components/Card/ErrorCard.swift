import SwiftUI

struct ErrorCard: View {
    let message: String
    let isVisible: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            if isVisible {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    
                    Text(message)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onDismiss()
                        }
                    }) {
                        Text("Dismiss")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding()
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

struct ErrorCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorCard(
                message: "An unexpected error occurred. Please try again later.",
                isVisible: true,
                onDismiss: { print("Dismiss button tapped") }
            )
            .previewDisplayName("Default")
            
            ErrorCard(
                message: "Network connection failed. Please check your internet connection and try again.",
                isVisible: true,
                onDismiss: { print("Dismiss button tapped") }
            )
            .previewDisplayName("Long Message")
            .previewLayout(.sizeThatFits)
        }
    }
}

 