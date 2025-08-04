//
//  FileIOUtils.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-01.
//

import Foundation
import SwiftUI

struct Vector3: Codable {
    var x: Float
    var y: Float
    var z: Float

    init(_ simd: SIMD3<Float>) {
        self.x = simd.x
        self.y = simd.y
        self.z = simd.z
    }

    func toSIMD() -> SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}

func exportWaypointsToJSON(_ waypoints: [Waypoint]) -> URL? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    do {
        let data = try encoder.encode(waypoints)

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("waypoints.json")

        try data.write(to: url)
        print("✅ Waypoints exported to: \(url.path)")
        return url
    } catch {
        print("❌ Export failed: \(error)")
        return nil
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to update
    }
}

