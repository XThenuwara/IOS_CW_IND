//
//  NotificationEntity+CoreDataProperties.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-12.
//
//

import Foundation
import CoreData


extension NotificationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationEntity> {
        return NSFetchRequest<NotificationEntity>(entityName: "NotificationEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var message: String?
    @NSManaged public var read_at: Bool
    @NSManaged public var send_at: Date?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var reference_id: String?

}

extension NotificationEntity : Identifiable {

}
