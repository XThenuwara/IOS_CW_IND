import Foundation

class DateUtils {
    static let shared = DateUtils()
    private let iso8601Formatter: ISO8601DateFormatter
    private let readableDateFormatter: DateFormatter
    
    private init() {
        iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        readableDateFormatter = DateFormatter()
        readableDateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
    }
    
    func parseISO8601Date(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        return iso8601Formatter.date(from: dateString)
    }
    
    func formatToReadableDate(_ date: Date?) -> String {
        guard let date = date else { return "No date" }
        return readableDateFormatter.string(from: date)
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "Time" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}