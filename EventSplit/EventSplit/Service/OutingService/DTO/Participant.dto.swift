import Foundation

struct ParticipantDTO: Codable {
    let id: String?
    let name: String
    let email: String?
    let phoneNumber: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phoneNumber
    }
}