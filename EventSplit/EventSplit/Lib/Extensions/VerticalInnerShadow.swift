import Foundation
import SwiftUI

extension View {
    func withVerticalInnerShadow() -> some View {
        self.overlay(
            VStack {
                // LinearGradient(
                //     gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.clear]),
                //     startPoint: .top,
                //     endPoint: .bottom
                // )
                // .frame(height: 10)
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, Color.gray.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 10)
            }
        )
    }
}