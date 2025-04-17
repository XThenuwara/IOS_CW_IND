//
//  EventServerModel.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-24.
//
import Foundation
import CoreData

struct EventDTO: Codable {
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
    
    struct TicketTypeDTO: Codable {
        let name: String?
        let price: Double?
        let totalQuantity: Int64?
        let soldQuantity: Int64?
    }
}


class EventService {
    private let serverURL = URL(string: "http://localhost:3000/event")!
    weak var coreDataModel: EventCoreDataModel?
    private let authCoreDataModel = AuthCoreDataModel.shared
    
    init(coreDataModel: EventCoreDataModel) {
        self.coreDataModel = coreDataModel
    }
    
    // List
    func fetchEventsFromServer() {
        print("fetch events from server called")
        
        if let user = AuthCoreDataModel.shared.currentUser {
        }
        
        guard let token = AuthCoreDataModel.shared.authEntity?.accessToken else {
            print("No access token available")
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        let requestResult = NetworkHelper.createRequest(url: serverURL, headers: headers)
        
        switch requestResult {
        case .success(let request):
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                NetworkHelper.handleResponse(data, response, error) { (result: Result<[EventDTO], AuthError>) in
                    switch result {
                    case .success(let eventDTOs):
                        DispatchQueue.main.async {
                            self.replaceEventStore(with: eventDTOs)
                        }
                    case .failure(let error):
                        print("Error fetching events: \(error)")
                    }
                }
            }.resume()
        case .failure(let error):
            print("Error creating request: \(error)")
        }
    }
    
    // Get By ID
    func getEvent(eventId: UUID, completion: @escaping (Result<EventDTO, Error>) -> Void) {
        let eventURL = serverURL.appendingPathComponent(eventId.uuidString)
        
        guard let token = AuthCoreDataModel.shared.authEntity?.accessToken else {
            completion(.failure(AuthError.noToken))
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        let requestResult = NetworkHelper.createRequest(url: eventURL, headers: headers)
        
        switch requestResult {
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                NetworkHelper.handleResponse(data, response, error) { (result: Result<EventDTO, AuthError>) in
                    switch result {
                    case .success(let eventDTO):
                        completion(.success(eventDTO))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    // Purchase Tickets
    func purchaseTickets(eventId: UUID, tickets: [PurchaseTicketItem], paymentMethod: String, completion: @escaping (Result<PurchasedTicketsDTO, Error>) -> Void) {
        let purchaseURL = serverURL.appendingPathComponent("\(eventId.uuidString)/purchase")
        
        guard let token = AuthCoreDataModel.shared.authEntity?.accessToken else {
            print("Error: No access token available for purchase tickets")
            completion(.failure(AuthError.noToken))
            return
        }
        
        let purchaseData = PurchaseTicketsDTO(
            eventId: eventId,
            tickets: tickets,
            paymentMethod: paymentMethod
        )
        
        var headers = [
            "Authorization": "Bearer \(token)"
        ]
    
        let requestResult = NetworkHelper.createRequest(
            url: purchaseURL,
            method: "POST",
            body: purchaseData,
            headers: headers
        )
        
        switch requestResult {
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                print("Purchase request sent to: \(purchaseURL)")
                NetworkHelper.handleResponse(data, response, error) { (result: Result<PurchasedTicketsDTO, AuthError>) in
                    switch result {
                    case .success(let purchaseDTO):
                        print("Purchase successful for event: \(eventId)")
                        completion(.success(purchaseDTO))
                    case .failure(let error):
                        print("Purchase failed: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }.resume()
        case .failure(let error):
            print("Failed to create purchase request: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func getPurchasedTickets(eventId: UUID, completion: @escaping (Result<[PurchasedTicketsDTO], Error>) -> Void) {
        let purchasedURL = serverURL.appendingPathComponent("\(eventId.uuidString)/purchased-tickets")
        
        guard let token = AuthCoreDataModel.shared.authEntity?.accessToken else {
            completion(.failure(AuthError.noToken))
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        let requestResult = NetworkHelper.createRequest(url: purchasedURL, headers: headers)
        
        switch requestResult {
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                NetworkHelper.handleResponse(data, response, error) { (result: Result<[PurchasedTicketsDTO], AuthError>) in
                    switch result {
                    case .success(let purchasedTickets):
                        completion(.success(purchasedTickets))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func getAllPurchasedTickets(completion: @escaping (Result<[PurchasedTicketsWithEventDTO], Error>) -> Void) {
        let purchasedURL = serverURL.appendingPathComponent("purchased-tickets/all")
        
        guard let token = AuthCoreDataModel.shared.authEntity?.accessToken else {
            completion(.failure(AuthError.noToken))
            return
        }
        
        let headers = ["Authorization": "Bearer \(token)"]
        let requestResult = NetworkHelper.createRequest(url: purchasedURL, headers: headers)
        
        switch requestResult {
        case .success(let request):
            URLSession.shared.dataTask(with: request) { data, response, error in
                NetworkHelper.handleResponse(data, response, error) { (result: Result<[PurchasedTicketsWithEventDTO], AuthError>) in
                    switch result {
                    case .success(let purchasedTickets):
                        completion(.success(purchasedTickets))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    // Helper Functions
    func replaceEventStore(with eventDTOs: [EventDTO]) {
        print("DEBUG: Starting replaceEventStore with \(eventDTOs.count) DTOs")
        guard let coreDataModel = self.coreDataModel else {
            print("DEBUG: CoreDataModel is nil, returning")
            return
        }
        
        print("DEBUG: Current eventStore count: \(coreDataModel.eventStore.count)")
        coreDataModel.eventStore.removeAll()
        print("DEBUG: EventStore cleared")
\
        for eventDTO in eventDTOs {
            if let eventEntity = convertToEventEntity(eventDTO: eventDTO, context: coreDataModel.container.viewContext) {
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
