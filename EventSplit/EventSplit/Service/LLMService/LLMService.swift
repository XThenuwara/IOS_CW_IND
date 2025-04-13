//
//  LLMService.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-13.
//
import Foundation
import Vision
import PhotosUI

struct ReceiptAnalysisResponse: Codable {
    let success: Bool
    let data: ReceiptAnalysis
}

struct ReceiptAnalysis: Codable {
    let totalAmount: Double?
    let date: String?
    let merchantName: String?
    let category: String?
}

class LLMService {
    private let serverURL = URL(string: "http://localhost:3000/analyze-receipt")!
    private let authModel = AuthCoreDataModel.shared
    
    private func createAuthenticatedRequest(url: URL, method: String = "POST") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authModel.authEntity?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    func analyzeReceipt(receiptText: String, completion: @escaping (Result<ReceiptAnalysis, Error>) -> Void) {
        var request = createAuthenticatedRequest(url: serverURL)
        
        let requestBody = ["receiptText": receiptText]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ [LLMService.analyzeReceipt] Failed to serialize request body: \(error)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [LLMService.analyzeReceipt] Network error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ [LLMService.analyzeReceipt] No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ReceiptAnalysisResponse.self, from: data)
                print("✅ [LLMService.analyzeReceipt] Analysis successful")
                DispatchQueue.main.async {
                    completion(.success(response.data))
                }
            } catch {
                print("❌ [LLMService.analyzeReceipt] Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func analyzeReceiptUsingVision(image: UIImage, completion: @escaping (Result<ReceiptAnalysis, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])))
            return
        }
        
        // Create VNImageRequestHandler with the image
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Create text recognition request
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process text"])))
                return
            }
            
            // Extract text from observations
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            // Process the recognized text to extract relevant information
            self.processRecognizedText(recognizedText) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
        
        // Configure the text recognition request
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        // Perform the request
        do {
            try requestHandler.perform([request])
        } catch {
            completion(.failure(error))
        }
    }
    
    private func processRecognizedText(_ text: String, completion: @escaping (Result<ReceiptAnalysis, Error>) -> Void) {
        // Regular expressions for extracting information
        let amountPattern = #"(?:total|amount|sum)[:\s]*[$]?\s*(\d+\.?\d*)"#
        let datePattern = #"(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})"#
        let merchantPattern = #"(?:merchant|store|restaurant):\s*([^\n]+)"#
        
        // Extract total amount
        let amountRegex = try? NSRegularExpression(pattern: amountPattern, options: [.caseInsensitive])
        let amountMatch = amountRegex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text))
        let amount = amountMatch.flatMap { match -> Double? in
            if let range = Range(match.range(at: 1), in: text) {
                return Double(text[range])
            }
            return nil
        }
        
        // Extract date
        let dateRegex = try? NSRegularExpression(pattern: datePattern, options: [])
        let dateMatch = dateRegex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text))
        let date = dateMatch.flatMap { match -> String? in
            if let range = Range(match.range(at: 1), in: text) {
                return String(text[range])
            }
            return nil
        }
        
        // Extract merchant name
        let merchantRegex = try? NSRegularExpression(pattern: merchantPattern, options: [.caseInsensitive])
        let merchantMatch = merchantRegex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text))
        let merchant = merchantMatch.flatMap { match -> String? in
            if let range = Range(match.range(at: 1), in: text) {
                return String(text[range])
            }
            return nil
        }
        
        // Determine category based on keywords in text
        let category = determineCategoryFromText(text)
        
        // Create ReceiptAnalysis object
        let analysis = ReceiptAnalysis(
            totalAmount: amount,
            date: date,
            merchantName: merchant,
            category: category
        )
        
        completion(.success(analysis))
    }
    
    private func determineCategoryFromText(_ text: String) -> String {
        let lowercasedText = text.lowercased()
        
        let categoryKeywords: [String: [String]] = [
            "Food": ["restaurant", "cafe", "food", "meal", "dinner", "lunch", "breakfast"],
            "Groceries": ["supermarket", "grocery", "market", "store"],
            "Transportation": ["taxi", "uber", "lyft", "fare", "transport"],
            "Entertainment": ["cinema", "movie", "theater", "concert"],
            "Shopping": ["mall", "retail", "shop", "boutique"],
            "Utilities": ["utility", "electric", "water", "gas", "bill"]
        ]
        
        for (category, keywords) in categoryKeywords {
            if keywords.contains(where: { lowercasedText.contains($0) }) {
                return category
            }
        }
        
        return "Other"
    }
}
