//
//  ContentView.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-23.
//

import SwiftUI
import CoreData

struct ContentView: View {   
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        Navbar(selectedTab: $selectedTab)
                            .padding(.bottom, 10)
                        
                        switch selectedTab {
                        case 0:
                            BrowseView()
                        case 1:
                            Text("Events View")
                        case 2:
                            Text("History View")
                        case 3:
                            Text("Groups View")
                        case 4:
                            Text("More View")
                        default:
                            EmptyView()
                        }
                    }
                }
                
                Tabbar(selectedTab: $selectedTab)
            }
        }
        .background(Color.primaryBackground)
    }
}

#Preview {
    ContentView()
}
