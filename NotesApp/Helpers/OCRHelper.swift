import Vision
import UIKit

class OCRHelper {
    static func extractText(from image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["es", "en"]
        request.usesLanguageCorrection = true
        request.minimumTextHeight = 0.01
        
        do {
            try requestHandler.perform([request])
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return nil
            }
            
            let text = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            return text
        } catch {
            print("OCR Error: \(error)")
            return nil
        }
    }
} 