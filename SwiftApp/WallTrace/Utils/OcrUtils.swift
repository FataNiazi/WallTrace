import Foundation
import CoreGraphics
import Vision
import UIKit

/// Utilites relevant to the OCRScanner used for text extraction from the environment.
final class OCRScanner {
    private(set) var recognizedTexts: Set<String> = []
    var isScanning: Bool = false

    private var request: VNRecognizeTextRequest!

    init() {
        request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self = self else { return }
            self.handleDetection(request: request, error: error)
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["English"]
        request.usesLanguageCorrection = true
    }

    func startScanning() {
        isScanning = true
        recognizedTexts.removeAll()
    }

    func stopScanning() {
        isScanning = false
    }

    func scan(cgImage: CGImage) {
        guard isScanning else { return }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    private func handleDetection(request: VNRequest, error: Error?) {
        guard let results = request.results as? [VNRecognizedTextObservation] else { return }
        
        for observation in results {
            if let text = observation.topCandidates(1).first?.string {
                recognizedTexts.insert(text)
            }
        }
    }

    func flushTexts() -> [String] {
        defer { recognizedTexts.removeAll() }
        return Array(recognizedTexts)
    }
}
