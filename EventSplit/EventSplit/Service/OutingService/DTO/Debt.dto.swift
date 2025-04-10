import Foundation

struct DebtDTO: Codable {
    let id: UUID
    let fromUserId: String
    let toUserId: String
    let amount: String
    let status: DebtStatus
    
    enum DebtStatus: String, Codable {
        case pending
        case paid
    }
}