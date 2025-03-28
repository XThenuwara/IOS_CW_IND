//
//  AuthEntity+CoreDataProperties.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-28.
//
//

import Foundation
import CoreData


extension AuthEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthEntity> {
        return NSFetchRequest<AuthEntity>(entityName: "AuthEntity")
    }

    @NSManaged public var accessToken: String?
    @NSManaged public var user: String?
    @NSManaged public var userEntity: AuthEntity?

}

extension AuthEntity : Identifiable {

}
