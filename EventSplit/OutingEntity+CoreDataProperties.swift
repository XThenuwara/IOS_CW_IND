//
//  OutingEntity+CoreDataProperties.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-10.
//
//

import Foundation
import CoreData


extension OutingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OutingEntity> {
        return NSFetchRequest<OutingEntity>(entityName: "OutingEntity")
    }

    @NSManaged public var activities: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var desc: String?
    @NSManaged public var due: Double
    @NSManaged public var id: UUID?
    @NSManaged public var linkedEvents: String?
    @NSManaged public var owner: UUID?
    @NSManaged public var participants: String?
    @NSManaged public var status: String?
    @NSManaged public var title: String?
    @NSManaged public var totalExpense: Double
    @NSManaged public var updatedAt: Date?
    @NSManaged public var debts: NSSet?
    @NSManaged public var outingActivity: ActivityEntity?
    @NSManaged public var outingEvent: OutingEventEntity?

}

// MARK: Generated accessors for debts
extension OutingEntity {

    @objc(addDebtsObject:)
    @NSManaged public func addToDebts(_ value: DebtEntity)

    @objc(removeDebtsObject:)
    @NSManaged public func removeFromDebts(_ value: DebtEntity)

    @objc(addDebts:)
    @NSManaged public func addToDebts(_ values: NSSet)

    @objc(removeDebts:)
    @NSManaged public func removeFromDebts(_ values: NSSet)

}

extension OutingEntity : Identifiable {

}
