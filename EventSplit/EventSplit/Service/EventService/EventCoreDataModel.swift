//
//  EventCoreDataModel.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-24.
//
import SwiftUI
import CoreData


class EventCoreDataModel: ObservableObject {
    let container: NSPersistentContainer
    @Published var eventStore: [EventEntity] = []
    lazy var serverModel = EventServerModel(coreDataModel: self)

    init() {
        container = NSPersistentContainer(name: "EventSplit")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("ERROR LOADING CORE DATA STORES: \(error)")
            } else {
                print("successfully loaded the core data")
            }
        }
    }

    func fetchEvents() {
        let request = NSFetchRequest<EventEntity>(entityName: "EventEntity")
        do {
            eventStore = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching events: \(error)")
        }
    }

    func addEvent(name: String, description: String) {
        let newEvent = EventEntity(context: container.viewContext)
        newEvent.title = name
        newEvent.desc = description
        saveData()
    }

    func saveData() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error Fetching Data: \(error)")
        }
    }

    func fetchEventsFromServer() {
        serverModel.fetchEventsFromServer()
    }
}

struct EventCoreDataModelPreview: View {
    @StateObject var viewModel = EventCoreDataModel()
    
    var body: some View {
        VStack() {
            Text("Hello World")
            // Display the events
            List {
                ForEach(viewModel.eventStore, id: \.id) { event in
                    VStack(alignment: .leading) {
                        Text(event.title ?? "Unknown Title").font(.headline)
                        Text(event.desc ?? "No Description").font(.subheadline)
                    }
                }
            }
            Button(action: {
                viewModel.fetchEventsFromServer()
            }) {
                Text("Fetch")
            }
        }
        .onAppear {
            // Call the fetchEventsFromServer() method when the view appears
            viewModel.fetchEventsFromServer()
            viewModel.fetchEvents() // Also fetch from Core Data on appear
        }
    }
}

struct EventCoreDataModelPreview_Previews: PreviewProvider {
    static var previews: some View {
        EventCoreDataModelPreview()
    }
}
