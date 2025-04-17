import Foundation
    
    struct ActivityDTO: Codable {
        let id: UUID
        let title: String
        let description: String
        private let amountString: String
        let paidById: String?
        let participants: [String]
        let references: [String]?
        let createdAt: String
        let updatedAt: String
        
        var amount: Double {
            return Double(amountString) ?? 0.0
        }
        
        init(id: UUID, title: String, description: String, amountString: String, paidById: String?, participants: [String], references: [String]?, createdAt: String, updatedAt: String) {
            self.id = id
            self.title = title
            self.description = description
            self.amountString = amountString
            self.paidById = paidById
            self.participants = participants
            self.references = references
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case description
            case amountString = "amount"
            case paidById
            case participants
            case references
            case createdAt
            case updatedAt
        }
    }


struct ActivityResponse: Codable {
    let id: UUID
    let title: String
    let description: String
    let amount: Double
    let paidById: String?
    let participants: [String]
    let references: [String]?
    let createdAt: String
    let updatedAt: String
}