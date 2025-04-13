//
//  TicketDTO.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-13.
//
import Foundation

struct TicketDTO: Codable, Identifiable {
    var id: String?
    let name: String
    let price: Double
    let totalQuantity: Int
    let soldQuantity: Int
    
    var available: Int {
        totalQuantity - soldQuantity
    }
}

