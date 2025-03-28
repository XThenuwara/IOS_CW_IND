//
//  OutingEntity+CoreDataProperties.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-28.
//
//

import Foundation
import CoreData


extension OutingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OutingEntity> {
        return NSFetchRequest<OutingEntity>(entityName: "OutingEntity")
    }

    @NSManaged public var desc: String?
    @NSManaged public var id: UUID?
    @NSManaged public var owner: UUID?
    @NSManaged public var participants: String?
    @NSManaged public var status: String?
    @NSManaged public var title: String?
    @NSManaged public var activities: String?
    @NSManaged public var totalExpense: Double
    @NSManaged public var due: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var linkedEvents: String?
    @NSManaged public var outingActivity: ActivityEntity?
    @NSManaged public var outingEvent: OutingEventEntity?
    @NSManaged public var outingUser: UserEntity?

}

extension OutingEntity : Identifiable {

}
