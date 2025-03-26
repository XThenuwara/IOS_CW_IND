//
//  EventSplitApp.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-23.
//

import SwiftUI

@main
struct EventSplitApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
