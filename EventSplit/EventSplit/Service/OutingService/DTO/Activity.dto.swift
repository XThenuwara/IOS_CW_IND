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
