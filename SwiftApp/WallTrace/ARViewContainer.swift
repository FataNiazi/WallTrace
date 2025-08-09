import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView

    let headingProvider: HeadingProvider
    let onPositionUpdate: (SIMD3<Float>) -> Void
    let ocrScanner: OCRScanner
    @ObservedObject var arrowController: ArrowController
    @ObservedObject var navigationManager: NavigationManager

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    final class Coordinator {
        let parent: ARViewContainer
        var timer: Timer?
        var northCorrectionDeg: Double?
        var headingCancellable: AnyCancellable?

        init(parent: ARViewContainer) {
            self.parent = parent

            // Lock the FIRST valid heading; remove this if you want live heading always
            headingCancellable = parent.headingProvider.$headingDeg
                .compactMap { $0 }
                .removeDuplicates()
                .sink { [weak self] deg in
                    guard let self else { return }
                    if self.northCorrectionDeg == nil { self.northCorrectionDeg = deg }
                }
        }

        deinit { headingCancellable?.cancel() }
    }

    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arrowController.setARView(arView)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)

        let coord = context.coordinator
        coord.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak arView, weak coord] _ in
            guard let arView, let coord else { return }
            guard let frame = arView.session.currentFrame else { return }

            let t = frame.camera.transform
            let rawAR = SIMD3<Float>(t.columns.3.x, t.columns.3.y, t.columns.3.z)

            // Use locked heading if present; else live; else 0
            let headingDeg = coord.northCorrectionDeg ?? headingProvider.headingDeg ?? 0
            let arNorthAligned = Coord.rotateToNorthYAxis(rawAR, headingDegrees: headingDeg)
            let enu = Coord.arKitToENU(arNorthAligned)

            onPositionUpdate(enu)
            navigationManager.updateCurrentPosition(enu)
            updateNavigationArrows()

            // OCR
            if ocrScanner.isScanning {
                let ciImage = CIImage(cvPixelBuffer: frame.capturedImage)
                let ciCtx = CIContext()
                if let cgImage = ciCtx.createCGImage(ciImage, from: ciImage.extent) {
                    ocrScanner.scan(cgImage: cgImage)
                }
            }
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // nothing to do here; we drive via timer
    }

    static func dismantleUIView(_ uiView: ARView, coordinator: Coordinator) {
        coordinator.timer?.invalidate()
        coordinator.timer = nil
        coordinator.headingCancellable?.cancel()
    }

    // MARK: - Helpers
    func updateNavigationArrows() {
        guard !navigationManager.path.isEmpty,
              navigationManager.currentWaypoint != nil,
              navigationManager.nextWaypoint != nil,
              let directionVector = navigationManager.currentDirection
        else {
            arrowController.removeArrow(id: "user_direction")
            arrowController.removeArrow(id: "waypoint_target")
            return
        }

        // ENU target, then convert to AR
        let nextENU = navigationManager.lastVirtualPosition + directionVector
        var nextAR = Coord.enuToARKit(nextENU)
        nextAR.y = -0.5 // keep on your chosen floor

        if arrowController.arrowExists("user_direction") {
            arrowController.updateArrowTarget(id: "user_direction", targetPosition: nextAR)
        } else {
            arrowController.spawnArrow(
                id: "user_direction",
                at: nil,
                pointingTo: nextAR,
                scale: 1,
                followsCamera: true
            )
        }

        if arrowController.arrowExists("waypoint_target") {
            arrowController.moveArrow(id: "waypoint_target", to: nextAR)
        } else {
            arrowController.spawnArrow(
                id: "waypoint_target",
                at: nextAR,
                pointingTo: nil,
                scale: 1,
                followsCamera: false
            )
        }
    }
}
