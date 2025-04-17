import Foundation

enum AuthError: Error {
    case noToken
    case invalidCredentials
    case networkError
    case serverError(String)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .noToken:
            return "No token found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection error"
        case .serverError(let message):
            return message
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
