import Foundation
import simd

/// This class is used to handle user navigation and the logic related to the sequence of waypoints
///
class NavigationManager: ObservableObject {
    @Published var path: [UUID] = []
    @Published var currentIndex: Int = 0
    @Published var currentDirection: SIMD3<Float>? = nil     // ENU, z forced to 0
    @Published var remainingOffset: SIMD3<Float>? = nil      // ENU, z forced to 0

    private var currentPosition: SIMD3<Float> = .zero        // ENU
    private(set) var lastVirtualPosition: SIMD3<Float> = .zero // ENU, z stays 0

    var waypoints: [Waypoint] = []

    // ——— helpers: make vectors planar (drop Z) and measure planar distance ———
    private func planar(_ v: SIMD3<Float>) -> SIMD3<Float> { SIMD3<Float>(v.x, v.y, 0) }
    private func planarDistance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
        let dx = a.x - b.x, dy = a.y - b.y
        return sqrt(dx*dx + dy*dy)
    }

    // How close (in meters) we must be to consider the next waypoint reached
    private let reachThreshold: Float = 0.5

    var currentWaypoint: Waypoint? {
        guard currentIndex < path.count else { return nil }
        return waypoints.first(where: { $0.id == path[currentIndex] })
    }

    var nextWaypoint: Waypoint? {
        guard currentIndex + 1 < path.count else { return nil }
        return waypoints.first(where: { $0.id == path[currentIndex + 1] })
    }

    func startPath(_ path: [UUID], waypoints: [Waypoint]) {
        self.path = path
        self.waypoints = waypoints
        self.currentIndex = 0
        lastVirtualPosition = .zero                      // z = 0 
        updateDirection()
    }

    private func updateDirection() {
        currentDirection = currentDirectionVector()
    }

    func updatePosition(relativeOffset: SIMD3<Float>) {
        // relativeOffset is ENU; we only compare in the XY plane
        guard let current = currentWaypoint,
              let next = nextWaypoint,
              let expectedOffsetENU = current.neighbors[next.id] else {
            currentDirection = nil
            return
        }

        let expectedPlanar = planar(expectedOffsetENU)
        let observedPlanar = planar(relativeOffset)

        let distance = planarDistance(observedPlanar, expectedPlanar)
        if distance < reachThreshold {
            currentIndex = min(currentIndex + 1, path.count - 1)
            // advance the virtual position only by the planar component
            lastVirtualPosition += expectedPlanar
            // keep z pinned to 0 (paranoid clamp)
            lastVirtualPosition.z = 0
            updateDirection()
            print("✅ Reached waypoint \(currentIndex) of \(path.count)")
        }
    }

    func updateCurrentPosition(_ positionENU: SIMD3<Float>) {
        currentPosition = positionENU

        let relBefore = currentPosition - lastVirtualPosition

        updatePosition(relativeOffset: relBefore)

        // Recompute relative after any advancement
        let relAfter = currentPosition - lastVirtualPosition

        if let current = currentWaypoint,
           let next = nextWaypoint,
           let expected = current.neighbors[next.id] {
            remainingOffset = planar(expected - relAfter)   // publish advancement
        } else {
            remainingOffset = nil
        }
    }

    func currentDirectionVector() -> SIMD3<Float>? {
        guard let current = currentWaypoint,
              let next = nextWaypoint,
              let offsetENU = current.neighbors[next.id] else { return nil }
        // return planar direction (z = 0)
        return planar(offsetENU)
    }

    func reset() {
        path = []
        currentIndex = 0
        lastVirtualPosition = .zero
        currentPosition = .zero
        currentDirection = nil
        remainingOffset = nil
    }

}
