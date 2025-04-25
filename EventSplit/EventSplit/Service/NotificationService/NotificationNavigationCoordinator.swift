//
//  NotificationNavigationCoordinator.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
import Foundation
import SwiftUI

class NotificationNavigationCoordinator {
    static let shared = NotificationNavigationCoordinator()
    
    func navigateToOuting(id: String, navigationPath: Binding<NavigationPath>) {
        guard UUID(uuidString: id) != nil else {
            print("NotificationNavigationCoordinator.navigateToOuting: Invalid UUID format:", id)
            return
        }
        
        let outingService = OutingService(coreDataModel: OutingCoreDataModel.shared)
        outingService.getOuting(outingId: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let outingDTO):
                    navigationPath.wrappedValue.append(outingDTO)
                case .failure(let error):
                    print("NotificationNavigationCoordinator.navigateToOuting: Error fetching outing:", error)
                }
            }
        }
    }
    
    private func fetchFromLocalStorage(id: UUID, navigationPath: Binding<NavigationPath>) {
        let context = PersistenceController.shared.container.viewContext
        let request = OutingEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let outings = try context.fetch(request)
            if let outing = outings.first {
                DispatchQueue.main.async {
                    navigationPath.wrappedValue.append(outing)
                }
            } else {
                print("NotificationNavigationCoordinator.fetchFromLocalStorage: No outing found with ID:", id)
            }
        } catch {
            print("NotificationNavigationCoordinator.fetchFromLocalStorage: Error fetching outing:", error)
        }
    }
}
