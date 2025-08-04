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
    @State private var lastWaypointId: Int?
    var waypointIDs: [Int] {
        waypoints.map { $0.id }
    }
    
    // Export result States
    @State private var exportedFileURL: URL? = nil
    @State private var showShareSheet = false
    
    @State private var isScanningText = false
    private var ocrScanner = OCRScanner()

    var body: some View {
        
        VStack(spacing: 0){
            HStack(spacing: 0){
                Spacer()
                MoreMenuButton(
                    onExport: {
                        if let url = exportWaypointsToJSON(waypoints) {
                            exportedFileURL = url
                            showShareSheet = true
                        }
                    },
                    onResetWaypoints: resetWaypoints
                )
            }
            .background(Color.black)
            
            
            ZStack(alignment: .topLeading) {
                ARViewContainer(
                    headingProvider: headingProvider,
                    onPositionUpdate: { newPosition in
                        currentPosition = newPosition
                        
                        if let last = lastSavedPosition {
                            relativeOffset = newPosition - last
                        } else {
                            relativeOffset = nil
                        }
                    },
                    ocrScanner: ocrScanner
                )
                .edgesIgnoringSafeArea(.all)
                .aspectRatio(9/16, contentMode: .fit)
                .padding(.vertical, 8)
                
                // The UI layer on the ARView
                VStack{
                    PrevWaypointInfoView(
                        relativeOffset: relativeOffset
                    )
                    .sheet(isPresented: $showShareSheet) {
                        if let url = exportedFileURL {
                            ShareSheet(activityItems: [url])
                        }
                    }
                    
                    
                    Spacer()
                    
                    ControlView(
                        isScanning: isScanningText,
                                scanAction: {
                                    isScanningText = true
                        ocrScanner.startScanning()
                    },
                        saveWaypointAction: {
                            
                            var offset: SIMD3<Float>? = nil
                            if let last = lastSavedPosition {
                                offset = currentPosition - last
                                relativeOffset = offset
                            }
                            
                            ocrScanner.stopScanning()
                            
                            isScanningText = false
                            
                            let waypoint = Waypoint(
                                id: (waypoints.last?.id ?? -1 ) + 1,
                                previousId: lastWaypointId,
                                positionRelativeToLast: Vector3(offset ?? .zero),
                                texts: ocrScanner.flushTexts()
                            )
                            
                            waypoints.append(waypoint)
                            lastWaypointId = waypoint.id
                            lastSavedPosition = currentPosition
                        },
                        resetRelativePosAction: {
                            lastSavedPosition = currentPosition
                        },
                        lastWaypointOptions: waypointIDs,
                        lastWaypointID: $lastWaypointId
                        
                    )
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .background(Color.black)
        .frame(maxWidth: .infinity)
    }
    
    func resetWaypoints(){
        lastSavedPosition = nil
        relativeOffset = nil
        waypoints.removeAll()
        lastWaypointId = nil
        isScanningText = false
        ocrScanner.stopScanning()
        
    }

}



#Preview {
    ContentView()
}
