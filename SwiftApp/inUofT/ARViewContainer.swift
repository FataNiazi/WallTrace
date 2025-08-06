import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let headingProvider: HeadingProvider
    let onPositionUpdate: (SIMD3<Float>) -> Void
    let ocrScanner: OCRScanner
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        var initialHeading: Double? = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal]
            arView.session.run(config)

            // Capture heading ONCE
            if initialHeading == nil {
                initialHeading = headingProvider.currentHeading
            }
        }

        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            guard let frame = arView.session.currentFrame else { return }

            let transform = frame.camera.transform
            let rawPosition = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )

            // ✅ Use fixed heading if available
            let heading = initialHeading ?? 0.0
            let alignedPosition = rotateToNorthYAxis(position: rawPosition, headingDegrees: heading)

            onPositionUpdate(alignedPosition)

            // OCR
            if ocrScanner.isScanning {
                let pixelBuffer = frame.capturedImage
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext()
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    ocrScanner.scan(cgImage: cgImage)
                }
            }
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
