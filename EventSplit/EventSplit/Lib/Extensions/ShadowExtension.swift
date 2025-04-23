//
//  ShadowExtension.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-24.
//

import SwiftUI

extension View {
    func withShadow() -> some View {
        self.shadow(color: .lineBackground.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
