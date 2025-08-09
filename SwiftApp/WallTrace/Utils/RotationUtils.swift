import simd
import CoreLocation

/// Rotates ARKit position into a custom coordinate system where:
/// - Y points to North
/// - Z is vertical (elevation)
/// - X is perpendicular (east-west axis)
func rotateToNorthYAxis(position: SIMD3<Float>, headingDegrees: CLLocationDirection) -> SIMD3<Float> {
    // Remap ARKit (X right, Y up, Z back) → (X right, Y forward (north), Z elevation)
    let remapped = SIMD3<Float>(position.x, position.z, position.y)

    let headingRadians = Float(headingDegrees * .pi / 180.0)

    // Rotate horizontal plane so +Y points north
    let rotationMatrix = float3x3([
        SIMD3(cos(headingRadians), -sin(headingRadians), 0), // X'
        SIMD3(-sin(headingRadians),  -cos(headingRadians), 0), // Y' (north)
        SIMD3(0,                    0,                   1)  // Z' (elevation)
    ])

    return rotationMatrix * remapped
}

enum Coord {
    // ARKit (x=right, y=up, z=forward/back) -> ENU (E,N,U)
    static func arKitToENU(_ v: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(v.x, -v.z, v.y)
    }
    // ENU (E,N,U) -> ARKit
    static func enuToARKit(_ v: SIMD3<Float>) -> SIMD3<Float> {
        SIMD3<Float>(v.x, v.z, -v.y)
    }

    // Rotate a world-space point around Y by heading (degrees) to align to North
    @inline(__always)
    static func rotateToNorthYAxis(_ p: SIMD3<Float>, headingDegrees: Double) -> SIMD3<Float> {
        let θ = Float(-headingDegrees * .pi / 180)   // negative: world -> EN frame
        let c = cos(θ), s = sin(θ)
        return SIMD3<Float>(c*p.x + s*p.z, p.y, -s*p.x + c*p.z)
    }

    // Planar helpers (ENU, drop elevation)
    static func planar(_ v: SIMD3<Float>) -> SIMD3<Float> { .init(v.x, v.y, 0) }
    static func planarDistance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
        let dx = a.x - b.x, dy = a.y - b.y
        return sqrt(dx*dx + dy*dy)
    }
}
