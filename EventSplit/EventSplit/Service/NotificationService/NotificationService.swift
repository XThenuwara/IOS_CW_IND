//
//  NotificationService.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import Foundation
import CoreData

struct NotificationDTO: Codable {
    let id: UUID
    let type: String
    let title: String
    let message: String
    let referenceId: String 
    let sent_at: String
    let read_at: String?
}

class NotificationService {
    private let serverURL = URL(string: "http://localhost:3000/notification")!
    weak var coreDataModel: NotificationCoreDataModel?
    private let authModel = AuthCoreDataModel.shared
    
    init(coreDataModel: NotificationCoreDataModel) {
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
    
    func fetchNotifications() {
        let userId = authModel.currentUser?.id.uuidString.lowercased() ?? ""
        let url = serverURL.appendingPathComponent("unread/\(userId)")
        let request = createAuthenticatedRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching notifications: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let notifications = try JSONDecoder().decode([NotificationDTO].self, from: data)
                DispatchQueue.main.async {
                    self?.replaceNotificationStore(with: notifications)
                }
            } catch {
                print("Error decoding notifications: \(error)")
            }
        }.resume()
    }
    
    func markAsRead(id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = serverURL.appendingPathComponent("\(id)/read")
        var request = createAuthenticatedRequest(url: url, method: "PATCH")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                completion(.success(true))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to mark as read"])))
            }
        }.resume()
    }
    
    private func replaceNotificationStore(with notificationDTOs: [NotificationDTO]) {
        print("Received notifications: \(notificationDTOs)")
        guard let coreDataModel = self.coreDataModel else { return }
        
        coreDataModel.notificationStore.removeAll()
        
        for notificationDTO in notificationDTOs {
            if let notificationEntity = convertToNotificationEntity(notificationDTO: notificationDTO, context: coreDataModel.container.viewContext) {
                coreDataModel.notificationStore.append(notificationEntity)
            }
        }
    }
    
    private func convertToNotificationEntity(notificationDTO: NotificationDTO, context: NSManagedObjectContext) -> NotificationEntity? {
        let entity = NotificationEntity(context: context)
        entity.id = notificationDTO.id
        entity.type = notificationDTO.type
        entity.title = notificationDTO.title
        entity.message = notificationDTO.message
        entity.reference_id = notificationDTO.referenceId
        entity.send_at = DateUtils.shared.parseISO8601Date(notificationDTO.sent_at)
        entity.read_at = notificationDTO.read_at != nil
        return entity
    }
}
