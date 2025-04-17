//
//  ErrorEnum.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
import Foundation

enum NetworkError: LocalizedError {
    case encodingError(String)
    case decodingError(String)
    case invalidResponse(Int)
    case serverError(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .encodingError(let details):
            return "Failed to encode request data: \(details)"
        case .decodingError(let details):
            return "Failed to decode response data: \(details)"
        case .invalidResponse(let statusCode):
            return "Invalid server response with status code: \(statusCode)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
