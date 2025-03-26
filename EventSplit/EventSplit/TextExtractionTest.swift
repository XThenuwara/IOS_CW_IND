import Vision
import UIKit

class TextExtractionTest {
    
    func extractText(from image: UIImage, completion: @escaping (String?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        // Create a new request to recognize text
        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Failed to recognize text: \(error)")
                completion(nil)
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Process the recognized text
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        // Configure the request
        request.recognitionLevel = .accurate
        
        // Create an image request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform image request: \(error)")
            completion(nil)
        }
    }
    
    // Example usage
    func processReceiptImage(_ image: UIImage) {
        extractText(from: image) { extractedText in
            if let text = extractedText {
                print("Extracted text from receipt:")
                print(text)
            } else {
                print("Failed to extract text from receipt")
            }
        }
    }
}

