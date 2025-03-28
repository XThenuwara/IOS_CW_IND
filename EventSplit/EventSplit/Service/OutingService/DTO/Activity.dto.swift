    import Foundation
    
    struct ActivityDTO: Codable {
        let id: UUID
        let title: String
        let amount: Double
        let paidBy: UserDTO
        let splitBetween: [UserDTO]
    }