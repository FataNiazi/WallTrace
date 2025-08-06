//
//  Waypoint.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-01.
//

import Foundation
import simd

struct Waypoint: Identifiable, Codable {
    let id: Int
    let previousId: Int?
    let positionRelativeToLast: Vector3
    let texts: [String]
}

