//
//  AuthResponse.dto.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-03-28.
//
import Foundation

struct AuthResponse: Codable {
    let accessToken: String
    let user: UserDTO
}
 
