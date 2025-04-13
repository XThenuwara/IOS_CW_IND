//
//  TextExtractor.swift
//  EventSplit
//
//  Created by Yasas Hansaka Thenuwara on 2025-04-13.
//
import Vision
import UIKit

class TextExtractor {
    static func extractText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("❌ Failed to recognize text: \(error)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        request.recognitionLevel = .accurate
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("❌ Failed to perform text recognition: \(error)")
            completion(nil)
        }
    }
}
