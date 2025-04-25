import Foundation

struct PurchaseTicketItem: Codable {
    let ticketType: String
    let quantity: Int
}

struct PurchaseTicketsDTO: Codable {
    let eventId: UUID
    let outingId: UUID?
    let tickets: [PurchaseTicketItem]
    let paymentMethod: String
}

struct PurchasedTicketsDTO: Codable {
    let id: UUID
    let eventId: UUID
    let userId: UUID
    let outingId: UUID?
    let ticketType: String
    let quantity: Int
    
    let unitPrice: String
    let totalAmount: String
    let status: String
    let paymentMethod: String
    let paymentReference: String
    let createdAt: String
    let updatedAt: String
}


struct PurchasedTicketsCreateDTO: Codable {
    let id: UUID
    let eventId: UUID
    let userId: UUID
    let outingId: UUID?
    let ticketType: String
    let quantity: Int
    
    let unitPrice: Double
    let totalAmount: Double
    let status: String
    let paymentMethod: String
    let paymentReference: String
    let createdAt: String
    let updatedAt: String
}