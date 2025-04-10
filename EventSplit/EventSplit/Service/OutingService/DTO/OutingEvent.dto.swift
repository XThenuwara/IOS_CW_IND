import Foundation

struct OutingEventDTO: Codable {
        let id: UUID
        let tickets: [String]
        let event: EventDTO
}
