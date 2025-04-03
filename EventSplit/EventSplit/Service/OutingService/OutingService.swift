import Foundation
import CoreData

struct OutingDTO: Codable {
    let id: UUID
    let title: String
    let description: String
    let owner: UserDTO
    let participants: [String]  // Changed from [UserDTO] to [String]
    let activities: [ActivityDTO]?
    let outingEvent: OutingEventDTO?
    let status: OutingStatus
    let createdAt: String
    let updatedAt: String
}

class OutingService {
    private let serverURL = URL(string: "http://localhost:3000/outing")!
    weak var coreDataModel: OutingCoreDataModel?
    private let authModel = AuthCoreDataModel.shared
    
    init(coreDataModel: OutingCoreDataModel) {
        self.coreDataModel = coreDataModel
    }
    
    private func createAuthenticatedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authModel.currentUser?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func fetchOutings() {
        let request = createAuthenticatedRequest(url: serverURL)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
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
                let outingDTOs = try JSONDecoder().decode([OutingDTO].self, from: data)
                DispatchQueue.main.async {
                    self.replaceOutingStore(with: outingDTOs)
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
    }

    func createOuting(
        title: String,
        description: String,
        eventId: String? = nil,
        participants: [String]? = nil,
        completion: @escaping (Result<OutingDTO, Error>) -> Void
    ) {
        var newOuting: [String: Any] = [
            "title": title,
            "description": description,
        ]
        
        if let eventId = eventId {
            newOuting["eventId"] = eventId
        }
        
        if let participants = participants {
            newOuting["participants"] = participants
        }
        
        var request = createAuthenticatedRequest(url: serverURL, method: "POST")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: newOuting)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let outingDTO = try JSONDecoder().decode(OutingDTO.self, from: data)
                DispatchQueue.main.async {
                    if let outingEntity = self?.convertToOutingEntity(outingDTO: outingDTO, context: self?.coreDataModel?.container.viewContext ?? NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)) {
                        self?.coreDataModel?.outingStore.append(outingEntity)
                    }
                    completion(.success(outingDTO))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    // Helper Methods
    func replaceOutingStore(with outingDTOs: [OutingDTO]) {
        guard let coreDataModel = self.coreDataModel else { return }
        
        coreDataModel.outingStore.removeAll()
        
        for outingDTO in outingDTOs {
            if let outingEntity = convertToOutingEntity(outingDTO: outingDTO, context: coreDataModel.container.viewContext) {
                coreDataModel.outingStore.append(outingEntity)
            }
        }
        
        print("outingStore replaced with \(coreDataModel.outingStore.count) outings")
    }
    
    func convertToOutingEntity(outingDTO: OutingDTO, context: NSManagedObjectContext) -> OutingEntity? {
        let outingEntity = OutingEntity(context: context)
        
        outingEntity.id = outingDTO.id
        outingEntity.title = outingDTO.title
        outingEntity.desc = outingDTO.description
        
        // Store participants directly as they are already strings
        do {
            let participantsData = try JSONEncoder().encode(outingDTO.participants)
            outingEntity.participants = String(data: participantsData, encoding: .utf8)
        } catch {
            print("Error encoding participants: \(error)")
        }
        
        // Convert activities to JSON string
        if let activities = outingDTO.activities {
            do {
                let activitiesData = try JSONEncoder().encode(activities)
                outingEntity.activities = String(data: activitiesData, encoding: .utf8)
            } catch {
                print("Error encoding activities: \(error)")
            }
        }
        
        // Convert outingEvent to OutingEventEntity
        if let outingEvent = outingDTO.outingEvent {
            let outingEventEntity = OutingEventEntity(context: context)
            outingEventEntity.id = outingEvent.id
            outingEventEntity.outing = outingEntity
            
            // Fetch event details using EventService
            let eventService = EventService(coreDataModel: EventCoreDataModel())
            eventService.getEvent(eventId: outingEvent.eventId) { result in
                switch result {
                case .success(let eventDTO):
                    if let eventEntity = eventService.convertToEventEntity(eventDTO: eventDTO, context: context) {
                        outingEventEntity.event = eventEntity
                    }
                case .failure(let error):
                    print("Error fetching event: \(error)")
                }
            }
            
            if let ticketsData = try? JSONEncoder().encode(outingEvent.tickets) {
                outingEventEntity.tickets = String(data: ticketsData, encoding: .utf8)
            }
            
            outingEventEntity.createdAt = DateUtils.shared.parseISO8601Date(outingDTO.createdAt)
            outingEventEntity.updatedAt = DateUtils.shared.parseISO8601Date(outingDTO.updatedAt)
            outingEntity.outingEvent = outingEventEntity
        }
        
        
        // Calculate total expense from activities
        outingEntity.totalExpense = outingDTO.activities?.reduce(0.0) { $0 + $1.amount } ?? 0.0
        outingEntity.createdAt = DateUtils.shared.parseISO8601Date(outingDTO.createdAt)
        outingEntity.updatedAt = DateUtils.shared.parseISO8601Date(outingDTO.updatedAt)
        outingEntity.status = outingDTO.status.rawValue
        
        return outingEntity
    }
}

