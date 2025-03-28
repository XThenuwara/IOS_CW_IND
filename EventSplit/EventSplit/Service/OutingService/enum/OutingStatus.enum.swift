import Foundation

enum OutingStatus: String, Codable {
    case draft = "draft"
    case inProgress = "in_progress"
    case unsettled = "unsettled"
    case settled = "settled"
}
