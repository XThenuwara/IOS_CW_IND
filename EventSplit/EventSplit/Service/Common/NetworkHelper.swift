//
//  NetworkHelper.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-16.
//
//
import Foundation

struct APIErrorResponse: Codable {
    let message: String
    let error: String
    let statusCode: Int
}

class NetworkHelper {
    static func createRequest(
        url: URL,
        method: String = "GET",
        headers: [String: String]? = nil
    ) -> Result<URLRequest, AuthError> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return .success(request)
    }
    
    static func createRequest<T: Codable>(
        url: URL,
        method: String = "GET",
        body: T,
        headers: [String: String]? = nil
    ) -> Result<URLRequest, AuthError> {
        print("Creating request for URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add headers
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Encode request body
        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
            
            // Debug logging
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request Body: \(jsonString)")
            }
        } catch {
            print("Error encoding request body: \(error)")
            return .failure(.unknown)
        }
        
        return .success(request)
    }
    
    static func handleResponse<T: Codable>(_ data: Data?, _ response: URLResponse?, _ error: Error?, completion: @escaping (Result<T, AuthError>) -> Void) {
        // print("========== DEBUG INFO ==========")
        if let data = data {
           //print("Response Data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
        }
        if let response = response as? HTTPURLResponse {
            //print("Response Status Code: \(response.statusCode)")
            // print("Response Headers: \(response.allHeaderFields)")
            
            // Handle HTTP error status codes
            if response.statusCode >= 400 {
                do {
                    let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data ?? Data())
                    completion(.failure(.serverError(errorResponse.message)))
                    return
                } catch {

                    completion(.failure(.unknown))
                    return
                }
            }
        }
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(.failure(.networkError))
            return
        }
        // print("==============================")
        
        guard let data = data else {
            completion(.failure(.unknown))
            return
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedResponse))
        } catch {
            print("Error decoding response: \(error)")
            completion(.failure(.unknown))
        }
    }
}
