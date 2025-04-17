import Foundation

struct PurchasedTicketsWithEventDTO: Codable {
    let id: UUID
    let eventId: UUID
    let userId: UUID
    let ticketType: String
    let quantity: Int
    let unitPrice: String
    let totalAmount: String
    let status: String
    let paymentMethod: String
    let paymentReference: String
    let createdAt: String
    let updatedAt: String
    
    // Event details
    let event: EventDTO
}