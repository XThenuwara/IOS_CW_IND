//
//  NotificationHandlerService.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
class NotificationHandlerService {
    static let shared = NotificationHandlerService()
    
    func handleNotificationTap(type: String, referenceId: String) -> NotificationNavigation? {
        guard let notificationType = NotificationType(rawValue: type) else { return nil }
        
        switch notificationType {
        case .addedToOuting:
            return .outing(id: referenceId)
        case .addedToActivity:
            return .activity(id: referenceId)
        case .settleUpReminder:
            return .settleUp(id: referenceId)
        case .addedToGroup:
            return .group(id: referenceId)
        }
    }
}

enum NotificationNavigation {
    case outing(id: String)
    case activity(id: String)
    case settleUp(id: String)
    case group(id: String)
}