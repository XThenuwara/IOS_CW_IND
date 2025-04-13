//
//  BorderExtension.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-27.
//

import SwiftUI

extension View {
    func withBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    func withBorder(color: Color = .gray, opacity: Double = 0.3, radius: CGFloat = 100, lineWidth: CGFloat = 1) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius)
                .stroke(color.opacity(opacity), lineWidth: lineWidth)
        )
    }
}

