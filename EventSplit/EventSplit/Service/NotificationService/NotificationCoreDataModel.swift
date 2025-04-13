//
//  NotificationCoreDataModel.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import SwiftUI
import CoreData

class NotificationCoreDataModel: ObservableObject {
    static let shared = NotificationCoreDataModel()
    let container: NSPersistentContainer
    lazy var serverModel = NotificationService(coreDataModel: self)
    @Published var notificationStore: [NotificationEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "EventSplit")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("ERROR LOADING CORE DATA STORES: \(error)")
            }
        }
    }
    
    func fetchNotifications(completion: @escaping ([NotificationEntity]) -> Void = { _ in }) {
        serverModel.fetchNotifications()
        let request = NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
        request.predicate = NSPredicate(format: "read_at == %@", NSNumber(value: false))
        
        do {
            notificationStore = try container.viewContext.fetch(request)
            completion(notificationStore)
        } catch let error {
            print("Error fetching notifications: \(error)")
            completion([])
        }
    }
    
    func markAsRead(notification: NotificationEntity) {
        serverModel.markAsRead(id: notification.id?.uuidString ?? "") { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    notification.read_at = true
                    self.saveData()
                }
            case .failure(let error):
                print("Error marking notification as read: \(error)")
            }
        }
    }
    
    func saveData() {
        do {
            try container.viewContext.save()
            fetchNotifications()
        } catch let error {
            print("Error saving data: \(error)")
        }
    }
    
    func clearAllNotifications() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NotificationEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
            try container.viewContext.save()
            notificationStore.removeAll()
        } catch let error {
            print("Error clearing notifications: \(error)")
        }
    }
}