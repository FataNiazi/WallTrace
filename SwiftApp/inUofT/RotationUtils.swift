//
//  RotationUtils.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-01.
//

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
