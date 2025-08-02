//
//  ContentView.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-07-22.
//

import SwiftUI
import RealityKit
import ARKit
import CoreLocation

struct ContentView: View {
    @StateObject private var headingProvider = HeadingProvider()
    @State private var currentPosition: SIMD3<Float> = .zero
    @State private var lastSavedPosition: SIMD3<Float>? = nil
    @State private var relativeOffset: SIMD3<Float>? = nil

    @State private var waypoints: [Waypoint] = []
    @State private var waypointCounter: Int = 0
    
    @State private var isScanningText = false
    private var ocrScanner = OCRScanner()

    var body: some View {
        ZStack(alignment: .topLeading) {
            ARViewContainer(
                headingProvider: headingProvider,
                onPositionUpdate: { currentPosition = $0 },
                ocrScanner: ocrScanner
            )
            .edgesIgnoringSafeArea(.all)

            PrevWaypointInfoView(
                currentPosition: currentPosition,
                relativeOffset: relativeOffset,
                onRecord: {
                    var offset: SIMD3<Float>? = nil
                    if let last = lastSavedPosition {
                        offset = currentPosition - last
                        relativeOffset = offset
                    }

                    let waypoint = Waypoint(
                        id: waypointCounter,
                        previousId: waypoints.last?.id,
                        positionRelativeToLast: Vector3(offset ?? .zero),
                        texts: ocrScanner.flushTexts()
                    )

                    waypoints.append(waypoint)
                    waypointCounter += 1
                    lastSavedPosition = currentPosition
                    ocrScanner.stopScanning()
                },
                onScan: {
                    isScanningText = true
                    ocrScanner.startScanning()
                },
                onExport: {
                    exportWaypointsToJSON(waypoints)
                }
            )
        }
    }

}



#Preview {
    ContentView()
}
