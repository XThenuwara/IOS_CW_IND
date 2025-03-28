import Foundation
import CoreData

struct OutingDTO: Codable {
    let id: UUID
    let title: String
    let description: String
    let owner: UserDTO
    let participants: [UserDTO]
    let activities: [ActivityDTO]?
    let outingEvents: [OutingEventDTO]?
    let status: OutingStatus
    let createdAt: String
    let updatedAt: String
}

class OutingServerModel {
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
    
    func fetchOutingsFromServer() {
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

    func createOuting(title: String, description: String, completion: @escaping (Result<OutingDTO, Error>) -> Void) {
        let newOuting = [
            "title": title,
            "description": description,
            "status": "in_progress"
        ]
        
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
        
        // Convert participants to JSON string
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
        
        if let linkedEvents = outingDTO.outingEvents {
            do {
                let linkedEventsData = try JSONEncoder().encode(linkedEvents)
                outingEntity.linkedEvents =  String(data: linkedEventsData, encoding: .utf8)
            } catch {
                print("Erro encodign linkedEvents: \(error)")
            }
        }
        
        // Calculate total expense from activities
        outingEntity.totalExpense = outingDTO.activities?.reduce(0.0) { $0 + $1.amount } ?? 0.0
        
        outingEntity.createdAt = DateUtils.shared.parseISO8601Date(outingDTO.createdAt)
        outingEntity.updatedAt = DateUtils.shared.parseISO8601Date(outingDTO.updatedAt)
        outingEntity.status = outingDTO.status.rawValue
        
        return outingEntity
    }
}

