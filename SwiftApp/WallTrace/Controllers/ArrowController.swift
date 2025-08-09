import SwiftUI
import RealityKit
import ARKit
import Combine

/// The controller for the AR direction arrow that will guide the user toward their target Waypoint.
/// 
class ArrowController: ObservableObject {
    private weak var arView: ARView?
    private var arrows: [String: ArrowEntity] = [:]
    private var updateSubscription: Cancellable?
    
    struct ArrowEntity {
        let anchor: AnchorEntity
        let entity: Entity
        var targetPosition: SIMD3<Float>?
        var isVisible: Bool = true
        var followsCamera: Bool = false
    }
    
    func setARView(_ arView: ARView) {
        self.arView = arView
        setupUpdateLoop()
    }
    
    private func setupUpdateLoop() {
        guard let arView = arView else { return }
        
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            self?.updateArrows()
        }
    }
    
    /// Spawn an arrow with a unique identifier
    /// - Parameters:
    ///   - id: Unique identifier for the arrow
    ///   - position: Optional world position. If nil, uses camera position
    ///   - targetPosition: Position the arrow should point towards (nil for waypoint markers)
    ///   - scale: Scale of the arrow
    ///   - followsCamera: If true, arrow will move with camera position
    func spawnArrow(
        id: String,
        at position: SIMD3<Float>? = nil,
        pointingTo targetPosition: SIMD3<Float>? = nil,
        scale: Float = 1,
        followsCamera: Bool = false
    ) {
        guard let arView = arView else {
            print("⚠️ ARView not available")
            return
        }
        
        // Remove existing arrow with same ID if it exists
        removeArrow(id: id)
        
        // Load arrow model
        guard let arrow = try? Entity.load(named: "arrow.usdz") else {
            print("⚠️ Failed to load arrow.usdz")
            return
        }
        
        arrow.scale = SIMD3<Float>(scale, scale, scale)
        
        // Determine spawn position
        let spawnPosition = position ?? getCurrentCameraPosition()
        
        // Create anchor and add to scene
        let anchor = AnchorEntity(world: spawnPosition)
        anchor.addChild(arrow)
        arView.scene.addAnchor(anchor)
        
        // Store arrow reference
        var arrowEntity = ArrowEntity(
            anchor: anchor,
            entity: arrow,
            targetPosition: targetPosition
        )
        arrowEntity.followsCamera = followsCamera
        arrows[id] = arrowEntity
        
        // Initial orientation setup
        updateArrowOrientation(id: id)
        
        print("✅ Spawned arrow '\(id)' at position \(spawnPosition)")
    }
    
    func arrowExists(_ id: String) -> Bool {
        return arrows[id] != nil
    }
    
    /// Update an existing arrow's target position
    func updateArrowTarget(id: String, targetPosition: SIMD3<Float>) {
        guard arrows[id] != nil else {
            print("⚠️ Arrow '\(id)' not found")
            return
        }
        
        arrows[id]?.targetPosition = targetPosition
        updateArrowOrientation(id: id)
    }
    
    /// Move an existing arrow to a new position
    func moveArrow(id: String, to position: SIMD3<Float>) {
        guard let arrowEntity = arrows[id] else {
            print("⚠️ Arrow '\(id)' not found")
            return
        }
        
        arrowEntity.anchor.transform.translation = position
        updateArrowOrientation(id: id)
    }
    
    /// Remove an arrow by ID
    func removeArrow(id: String) {
        guard let arrowEntity = arrows[id] else { return }
        
        arView?.scene.removeAnchor(arrowEntity.anchor)
        arrows.removeValue(forKey: id)
        
        print("🗑️ Removed arrow '\(id)'")
    }
    
    /// Remove all arrows
    func removeAllArrows() {
        for (id, _) in arrows {
            removeArrow(id: id)
        }
    }
    
    /// Show/hide an arrow
    func setArrowVisibility(id: String, isVisible: Bool) {
        guard var arrowEntity = arrows[id] else {
            print("⚠️ Arrow '\(id)' not found")
            return
        }
        
        arrowEntity.isVisible = isVisible
        arrowEntity.entity.isEnabled = isVisible
        arrows[id] = arrowEntity
    }
    
    /// Get all active arrow IDs
    var activeArrowIds: [String] {
        return Array(arrows.keys)
    }
    
    // MARK: - Private Methods
    
    private func updateArrows() {
        for (id, arrowEntity) in arrows {
            // Update position if it follows camera
            if arrowEntity.followsCamera {
                let cameraPosition = getCurrentCameraPosition()
                arrowEntity.anchor.transform.translation = cameraPosition
            }
            
            // Update orientation
            updateArrowOrientation(id: id)
        }
    }
    
    private func updateArrowOrientation(id: String) {
        guard let arrowEntity = arrows[id], arrowEntity.isVisible else { return }

        if let target = arrowEntity.targetPosition {
            let pos = arrowEntity.anchor.transform.translation

            // --- force horizontal aiming: drop Y, normalize on XZ plane
            var toTargetPlanar = SIMD3<Float>(target.x - pos.x, 0, target.z - pos.z)
            let len = simd_length(toTargetPlanar)
            if len < 1e-4 { return } // too close, keep current orientation
            toTargetPlanar /= len

            // yaw only: angle to rotate +Z to the planar direction
            let yaw = atan2f(toTargetPlanar.x, toTargetPlanar.z)
            let yawRot = simd_quatf(angle: yaw, axis: SIMD3<Float>(0, 1, 0))

            // If you use a model-correction (e.g., arrow asset points down), keep it here.
            // Otherwise, set modelCorrection = simd_quatf(angle: 0, axis: [0,1,0]).
            let modelCorrection = simd_quatf(angle: 0, axis: SIMD3<Float>(0,1,0))

            arrowEntity.entity.orientation = yawRot * modelCorrection
        } else {
            // Default: point forward, still horizontal
            arrowEntity.entity.orientation = simd_quatf(angle: 0, axis: SIMD3<Float>(0, 1, 0))
        }
    }

    
    private func getCurrentCameraPosition() -> SIMD3<Float> {
        guard let cameraTransform = arView?.session.currentFrame?.camera.transform else {
            return SIMD3<Float>(0, 0, 0)
        }
        
        let cameraPosition = SIMD3<Float>(
            cameraTransform.columns.3.x,
            cameraTransform.columns.3.y,
            cameraTransform.columns.3.z
        )
        
        // Project to floor level (adjust Y as needed)
        return SIMD3<Float>(cameraPosition.x, -0.5, cameraPosition.z)
    }
    
    deinit {
        updateSubscription?.cancel()
        removeAllArrows()
    }
}
