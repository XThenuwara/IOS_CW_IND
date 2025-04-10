//
//  DebtEntity+CoreDataProperties.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-10.
//
//

import Foundation
import CoreData


extension DebtEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DebtEntity> {
        return NSFetchRequest<DebtEntity>(entityName: "DebtEntity")
    }

    @NSManaged public var amount: Double
    @NSManaged public var fromUserId: String?
    @NSManaged public var id: UUID?
    @NSManaged public var status: String?
    @NSManaged public var toUserId: String?
    @NSManaged public var outing: OutingEntity?

}

extension DebtEntity : Identifiable {

}
