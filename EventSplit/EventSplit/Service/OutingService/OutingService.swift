
import Foundation
import CoreData
import SwiftUI

struct OutingDTO: Codable {
    let id: UUID
    let title: String
    let description: String
    let owner: UserDTO
    let participants: [String]
    let activities: [ActivityDTO]?
    let outingEvents: [OutingEventDTO]?
    let debts: [DebtDTO]?
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
        
        if let token = authModel.authEntity?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func fetchOutings() {
        let request = createAuthenticatedRequest(url: serverURL)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                print("[OutingService.fetchOutings] ⚠️ Self is nil, aborting")
                return
            }
            
            if let error = error {
                print("[OutingService.fetchOutings] ❌ Network error: \(error)")
                return
            }
            
            guard let data = data else {
                print("[OutingService.fetchOutings] ⚠️ No data received from server")
                return
            }
            
            // Log the raw data as string
            if let dataString = String(data: data, encoding: .utf8) {
                // print("[OutingService.fetchOutings] Raw Data:", dataString)
            } else {
                 print("[OutingService.fetchOutings] Data is not valid UTF-8")
            }
            
            do {
                let outingDTOs = try JSONDecoder().decode([OutingDTO].self, from: data)
                DispatchQueue.main.async {
                    self.replaceOutingStore(with: outingDTOs)
                }
            } catch {
                print("[OutingService.fetchOutings] ❌ Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("[OutingService.fetchOutings]    Missing key: \(key)")
                        print("[OutingService.fetchOutings]    Context: \(context)")
                    case .typeMismatch(let type, let context):
                        print("[OutingService.fetchOutings]    Type mismatch: expected \(type)")
                        print("[OutingService.fetchOutings]    Context: \(context)")
                    default:
                        print("[OutingService.fetchOutings]    Other decoding error: \(decodingError)")
                    }
                }
            }
        }.resume()
    }

     func getOuting(outingId: String, completion: @escaping (Result<OutingDTO, Error>) -> Void) {
        let outingURL = serverURL.appendingPathComponent(outingId)
        let request = createAuthenticatedRequest(url: outingURL)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌[OutingService.getOuting] Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌[OutingService.getOuting] No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let outingDTO = try JSONDecoder().decode(OutingDTO.self, from: data)
                completion(.success(outingDTO))
            } catch {
                print("❌[OutingService.getOuting] Decoding error: \(error)")
                completion(.failure(error))
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
                    completion(.success(outingDTO))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    // Activity
    func addActivity(
        title: String,
        description: String,
        amount: Double,
        participantIds: [String],
        paidById: String,
        outingId: String,
        references: [String]? = nil,
        completion: @escaping (Result<ActivityDTO, Error>) -> Void
    ) {
        
        let activityURL = serverURL.appendingPathComponent("activity")
        var request = createAuthenticatedRequest(url: activityURL, method: "POST")
        
        let activityData: [String: Any] = [
            "title": title,
            "description": description,
            "amount": amount,
            "participantIds": participantIds,
            "outingId": outingId,
            "paidById": paidById,
            "references": references ?? []
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: activityData)
        } catch {
            print("❌[OutingService.AddActivity] Failed to serialize request body: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌[OutingService.AddActivity] Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [OutingService.AddActivity] Response Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("❌[OutingService.AddActivity] No data received from server")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let activityResponse = try JSONDecoder().decode(ActivityResponse.self, from: data)
                let activityDTO = ActivityDTO(
                    id: activityResponse.id,
                    title: activityResponse.title,
                    description: activityResponse.description,
                    amountString: String(activityResponse.amount),
                    paidById: activityResponse.paidById,
                    participants: activityResponse.participants,
                    references: activityResponse.references,
                    createdAt: activityResponse.createdAt,
                    updatedAt: activityResponse.updatedAt
                )
                DispatchQueue.main.async {
                    completion(.success(activityDTO))
                }
            } catch {
                print("❌[OutingService.AddActivity] Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func uploadActivityImage(activityId: String, image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        let imageURL = serverURL.appendingPathComponent("activity/\(activityId)/image")
        var request = createAuthenticatedRequest(url: imageURL, method: "POST")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌[OutingService.uploadActivityImage] Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                print("✅ Image uploaded successfully")
                completion(.success(true))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"])))
            }
        }.resume()
    }
    
    func getActivityImages(activityId: String, completion: @escaping (Result<[URL], Error>) -> Void) {
        let imageURL = serverURL.appendingPathComponent("activity/\(activityId)/images")
        let request = createAuthenticatedRequest(url: imageURL)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌[OutingService.getActivityImages] Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌[OutingService.getActivityImages] No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ImageResponse.self, from: data)
                let urls = response.images.compactMap { URL(string: $0) }
                print("✅ Successfully fetched \(urls.count) images")
                completion(.success(urls))
            } catch {
                print("❌[OutingService.getActivityImages] Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    

    func updateDebtStatus(debtId: String, status: String, completion: @escaping (Result<DebtDTO, Error>) -> Void) {
        let debtURL = serverURL.appendingPathComponent("debt/\(debtId)/status")
        var request = createAuthenticatedRequest(url: debtURL, method: "PATCH")
        
        let statusData = ["status": status]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: statusData)
        } catch {
            print("❌[OutingService.updateDebtStatus] Failed to serialize request body: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌[OutingService.updateDebtStatus] Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌[OutingService.updateDebtStatus] No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let debtDTO = try JSONDecoder().decode(DebtDTO.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(debtDTO))
                }
            } catch {
                print("❌[OutingService.updateDebtStatus] Decoding error: \(error)")
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

        



    // Helper Methods
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
        if let outingEvent = outingDTO.outingEvents?.first {
            let outingEventEntity = OutingEventEntity(context: context)
            outingEventEntity.id = outingEvent.id
            outingEventEntity.outing = outingEntity
            
            let eventEntity = EventService(coreDataModel: EventCoreDataModel())
                .convertToEventEntity(eventDTO: outingEvent.event, context: context)
            outingEventEntity.event = eventEntity
            if let ticketsData = try? JSONEncoder().encode(outingEvent.tickets) {
                outingEventEntity.tickets = String(data: ticketsData, encoding: .utf8)
            }
            
            outingEventEntity.createdAt = DateUtils.shared.parseISO8601Date(outingDTO.createdAt)
            outingEventEntity.updatedAt = DateUtils.shared.parseISO8601Date(outingDTO.updatedAt)
            outingEntity.outingEvent = outingEventEntity
        }
        
        
        // Convert debts to DebtEntities and establish relationship
        if let debts = outingDTO.debts {
            print("[OutingService] Converting \(debts.count) debts from DTO")
            var debtEntities = Set<DebtEntity>()
            
            context.performAndWait {
                for debtDTO in debts {
                    let debtEntity = DebtEntity(context: context)
                    debtEntity.id = debtDTO.id
                    debtEntity.fromUserId = debtDTO.fromUserId
                    debtEntity.toUserId = debtDTO.toUserId
                    debtEntity.amount = Double(debtDTO.amount) ?? 0.0
                    debtEntity.status = debtDTO.status.rawValue
                    debtEntity.outing = outingEntity
                    debtEntities.insert(debtEntity)
                }
                
                outingEntity.debts = NSSet(set: debtEntities)
            }
            
            print("[OutingService] Created \(debtEntities.count) DebtEntities and assigned to OutingEntity")
        }
        
        // Calculate total expense from activities
        outingEntity.totalExpense = outingDTO.activities?.reduce(0.0) { $0 + $1.amount } ?? 0.0
        outingEntity.createdAt = DateUtils.shared.parseISO8601Date(outingDTO.createdAt)
        outingEntity.updatedAt = DateUtils.shared.parseISO8601Date(outingDTO.updatedAt)
        outingEntity.status = outingDTO.status.rawValue
        
        return outingEntity
    }

}

struct ImageResponse: Codable {
    let images: [String]
}


