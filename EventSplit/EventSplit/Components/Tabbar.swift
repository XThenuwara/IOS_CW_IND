//
//  Tabbar.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-21.
//
import SwiftUI

struct TabItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}

struct Tabbar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        TabItem(icon: "house", label: "Home"),
        TabItem(icon: "calendar", label: "Events"),
        TabItem(icon: "clock.arrow.circlepath", label: "Outings"),
        TabItem(icon: "person.2", label: "Groups"),
        TabItem(icon: "line.3.horizontal", label: "More")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 14))
                            .foregroundColor(selectedTab == index ? .black : .gray)
                        
                        Text(tab.label)
                            .font(.system(size: 12))
                            .foregroundColor(selectedTab == index ? .black : .gray)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 14)
        .background(Color.white)
        .cornerRadius(100)
        .withShadow()
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

#Preview {
    StatefulPreviewWrapper(0) { selectedTab in
        Tabbar(selectedTab: selectedTab)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
