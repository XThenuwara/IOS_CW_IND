//
//  EventServerModel.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-24.
//
import Foundation
import CoreData

struct EventDTO: Decodable {
    let id: UUID
    let title: String
    let description: String
    let eventType: String
    let locationName: String?
    let locationAddress: String?
    let locationLongitudeLatitude: String?
    let eventDate: String?
    let organizerName: String?
    let organizerPhone: String?
    let organizerEmail: String?
    let amenities: [String]?
    let requirements: [String]?
    let weatherCondition: String?
    let capacity: Int64?
    let sold: Int64?
    let ticketTypes: [TicketTypeDTO]?
    let createdAt: String?
    let updatedAt: String?
    
    struct TicketTypeDTO: Decodable, Encodable {
        let name: String?
        let price: Double?
        let totalQuantity: Int64?
        let soldQuantity: Int64?
    }
}


class EventServerModel {
    private let serverURL = URL(string: "http://localhost:3000/event")!
    weak var coreDataModel: EventCoreDataModel?
    
    init(coreDataModel: EventCoreDataModel) {
        self.coreDataModel = coreDataModel
    }
    
    func fetchEventsFromServer() {
        print("fetch events from server called")
        URLSession.shared.dataTask(with: serverURL) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let eventDTOs = try JSONDecoder().decode([EventDTO].self, from: data)
                DispatchQueue.main.async {
                    self.replaceEventStore(with: eventDTOs)
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
    }
    
    
    // Helper Functions
    func replaceEventStore(with eventDTOs: [EventDTO]) {
        guard let coreDataModel = self.coreDataModel else { return }
        
        // Clear the existing eventStore
        coreDataModel.eventStore.removeAll()
        
        // Convert ServerEvent to EventEntity and append to eventStore
        for eventDTO in eventDTOs {
            if let eventEntity = convertToEventEntity(eventDTO: eventDTO, context: coreDataModel.container.viewContext) {
                print("Data", eventEntity)
                coreDataModel.eventStore.append(eventEntity)
            }
        }
        
        print("eventStore replaced with \(coreDataModel.eventStore.count) events")
    }
    
    func convertToEventEntity(eventDTO: EventDTO, context: NSManagedObjectContext) -> EventEntity? {
        let eventEntity = EventEntity(context: context)
    
        eventEntity.id = eventDTO.id
        eventEntity.title = eventDTO.title
        eventEntity.desc = eventDTO.description
        eventEntity.locationName = eventDTO.locationName
        eventEntity.locationAddress = eventDTO.locationAddress
        eventEntity.locationGPS = eventDTO.locationLongitudeLatitude
        eventEntity.eventDate = DateUtils.shared.parseISO8601Date(eventDTO.eventDate)
        eventEntity.organizerName = eventDTO.organizerName
        eventEntity.organizerPhone = eventDTO.organizerPhone
        eventEntity.organizerEmail = eventDTO.organizerEmail
        eventEntity.weatherCondition = eventDTO.weatherCondition
        eventEntity.capacity = eventDTO.capacity ?? 0
        eventEntity.sold = eventDTO.sold ?? 0
        eventEntity.createdAt = DateUtils.shared.parseISO8601Date(eventDTO.createdAt)
        eventEntity.updatedAt = DateUtils.shared.parseISO8601Date(eventDTO.updatedAt)
        
        if let amenities = eventDTO.amenities {
            eventEntity.amenities = amenities.joined(separator: ",")
        }
        
        if let requirements = eventDTO.requirements {
            eventEntity.requirements = requirements.joined(separator: ",")
        }
        
        // Handle ticketTypes conversion
        if let ticketTypeDTOs = eventDTO.ticketTypes {
            do {
                let jsonData = try JSONEncoder().encode(ticketTypeDTOs)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    eventEntity.ticketTypes = jsonString
                }
            } catch {
                print("Error encoding ticketTypes: \(error)")
            }
        }

        if let eventType = EventTypeEnum(rawValue: eventDTO.eventType.lowercased()) {
            eventEntity.eventType = eventType.rawValue
        } else {
            eventEntity.eventType = EventTypeEnum.musical.rawValue
        }
        
        return eventEntity
    }
    
}
