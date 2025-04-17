//
//  OutingEventEntity+CoreDataProperties.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//

import Foundation
import CoreData


extension OutingEventEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OutingEventEntity> {
        return NSFetchRequest<OutingEventEntity>(entityName: "OutingEventEntity")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var tickets: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var event: EventEntity?
    @NSManaged public var outing: OutingEntity?

}

extension OutingEventEntity : Identifiable {

}
