//
//  EventKit.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import EventKit
import EventKitUI

class CalendarService {
    static let shared = CalendarService()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    func addEventToCalendar(
        title: String,
        description: String,
        startDate: Date?,
        completion: @escaping (Bool) -> Void
    ) {
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                let calendarEvent = EKEvent(eventStore: self.eventStore)
                calendarEvent.title = title
                calendarEvent.notes = description
                
                if let eventDate = startDate {
                    calendarEvent.startDate = eventDate
                    calendarEvent.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: eventDate) ?? eventDate
                } else {
                    calendarEvent.startDate = Date()
                    calendarEvent.endDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
                }
                
                calendarEvent.calendar = self.eventStore.defaultCalendarForNewEvents
                
                do {
                    try self.eventStore.save(calendarEvent, span: .thisEvent)
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } catch {
                    print("❌ Failed to save event to calendar:", error)
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    func checkIfEventExists(title: String, startDate: Date?) -> Bool {
        guard let startDate = startDate else { return false }
        
        // Create a predicate for events within the same day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: nil
        )
        
        // Fetch events matching the predicate
        let existingEvents = eventStore.events(matching: predicate)
        
        // Check if any event matches our title
        return existingEvents.contains { event in
            event.title.lowercased() == title.lowercased()
        }
    }
    
    func openEventInCalendar(title: String, startDate: Date) {
        let eventStore = EKEventStore()
        
        let predicate = eventStore.predicateForEvents(
            withStart: Calendar.current.date(byAdding: .hour, value: -1, to: startDate) ?? startDate,
            end: Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        if let event = events.first(where: { $0.title == title }) {
            let eventViewController = EKEventViewController()
            eventViewController.event = event
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                let navigationController = UINavigationController(rootViewController: eventViewController)
                rootViewController.present(navigationController, animated: true)
            }
        }
    }
}
