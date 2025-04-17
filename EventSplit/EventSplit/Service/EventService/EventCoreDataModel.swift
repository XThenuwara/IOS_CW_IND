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
    lazy var serverModel = EventService(coreDataModel: self)
    private let locationManager = LocationManager()

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

    func fetchFilteredEvents(distance: Int? = nil, type: EventTypeEnum? = nil, startDate: Date? = nil, endDate: Date? = nil) {
        print("📊 Starting filtered fetch - Distance: \(distance ?? 0)km, Type: \(type?.displayName ?? "All")")
        let request = NSFetchRequest<EventEntity>(entityName: "EventEntity")
        
        var predicates: [NSPredicate] = []

        if let type = type {
            predicates.append(NSPredicate(format: "eventType == %@", type.rawValue))
        }
        
        // Date filtering
        if let start = startDate {
            if let end = endDate {
                predicates.append(NSPredicate(format: "eventDate >= %@ AND eventDate <= %@", start as NSDate, end as NSDate))
            } else {
                predicates.append(NSPredicate(format: "eventDate >= %@", start as NSDate))
            }
        }
        
        if !predicates.isEmpty {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            request.predicate = compoundPredicate
            print("🔍 Applied predicates: \(compoundPredicate)")
        }
        
        do {
            var filteredEvents = try container.viewContext.fetch(request)
            
            // Post-fetch distance filtering
            if let distance = distance {
                filteredEvents = filteredEvents.filter { event in
                    guard let calculatedDistance = locationManager.calculateDistance(to: event.locationGPS) else {
                        print("❌ Could not calculate distance for event: \(event.title ?? "Unknown")")
                        return false
                    }
                    
                    let withinRange = calculatedDistance <= Double(distance)
                    return withinRange
                }
            }
            
            eventStore = filteredEvents
        } catch let error {
            print("❌ Error fetching filtered events: \(error)")
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
    
    // Server Methods
    func fetchEventsFromServer() {
        serverModel.fetchEventsFromServer()
    }
}

struct EventCoreDataModelPreview: View {
    @StateObject var viewModel = EventCoreDataModel()
    
    var body: some View {
        VStack() {
            Text("Hello World")
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
            viewModel.fetchEventsFromServer()
            viewModel.fetchEvents()
        }
    }
}

struct EventCoreDataModelPreview_Previews: PreviewProvider {
    static var previews: some View {
        EventCoreDataModelPreview()
    }
}
