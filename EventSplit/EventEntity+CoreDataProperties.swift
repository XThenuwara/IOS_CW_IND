//
//  EventEntity+CoreDataProperties.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//

import Foundation
import CoreData


extension EventEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEntity> {
        return NSFetchRequest<EventEntity>(entityName: "EventEntity")
    }

    @NSManaged public var amenities: String?
    @NSManaged public var capacity: Int64
    @NSManaged public var createdAt: Date?
    @NSManaged public var desc: String?
    @NSManaged public var eventDate: Date?
    @NSManaged public var eventType: String?
    @NSManaged public var id: UUID?
    @NSManaged public var locationAddress: String?
    @NSManaged public var locationGPS: String?
    @NSManaged public var locationName: String?
    @NSManaged public var organizerEmail: String?
    @NSManaged public var organizerName: String?
    @NSManaged public var organizerPhone: String?
    @NSManaged public var requirements: String?
    @NSManaged public var sold: Int64
    @NSManaged public var ticketTypes: String?
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var weatherCondition: String?
    @NSManaged public var outingEvent: OutingEventEntity?

}

extension EventEntity : Identifiable {

}
