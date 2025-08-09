//
//  DataCollectionView.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-04.
//

import SwiftUI
import RealityKit
import ARKit
import CoreLocation

struct DataCollectionView: View {
    let arView: ARViewContainer
    let ocrScanner: OCRScanner
    var onResetWaypoints: () -> Void
    
    @Binding var relativeOffset: SIMD3<Float>?
    @Binding var currentPosition: SIMD3<Float>
    @Binding var lastSavedPosition: SIMD3<Float>?
    @Binding var isScanningText: Bool
    @Binding var waypoints: [Waypoint]
    var waypointSummaries: [WaypointSummary] {
        waypoints.map { WaypointSummary(id: $0.id, name: $0.name) }
    }
    
    // Save Waypoint
    @State var lastWaypointId: UUID?
    @State private var showNamingAlert = false      // controls alert presentation
    @State private var newWaypointName = ""
    @State private var pendingOffset: SIMD3<Float>? = nil
    
    
    // Export Data
    @State var showShareSheet: Bool = false
    @State var exportedFileURL: URL?
    
    private var selectedIndexBinding: Binding<Int?> {
        Binding<Int?>(
            get: {
                guard
                    let id = lastWaypointId,
                    let idx = waypoints.firstIndex(where: { $0.id == id })
                else { return nil }        // nothing selected yet
                return idx
            },
            set: { newIdx in
                if
                    let idx = newIdx,
                    waypoints.indices.contains(idx)
                {
                    lastWaypointId = waypoints[idx].id   // propagate change back to model
                } else {
                    lastWaypointId = nil                 // “no selection” position on slider
                }
            }
        )
    }
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            arView
                .frame(maxWidth: .infinity) // fills width
                .aspectRatio(9 / 16, contentMode: .fit)
            
            // The UI layer on the ARView
            VStack{
                HStack(spacing: 0){
                    Spacer()
                    MoreMenuButton(
                        onExport: {
                            if let url = exportWaypointsToJSON(waypoints) {
                                exportedFileURL = url
                                showShareSheet = true
                            }
                        },
                        onResetWaypoints: onResetWaypoints
                    )
                }
                .background(Color("UofT Blue"))
                
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
                    saveWaypointAction: {if let last = lastSavedPosition {
                        let delta = currentPosition - last
                        pendingOffset = SIMD3<Float>(delta.x, delta.y, 0)

                    } else {
                        pendingOffset = nil
                    }
                        
                        ocrScanner.stopScanning()
                        isScanningText = false
                        
                        showNamingAlert = true
                    },
                    resetRelativePosAction: {
                        lastSavedPosition = currentPosition
                    },
                    waypointSummaries: waypointSummaries,
                    lastWaypointId: $lastWaypointId
                    
                )
                
                // Naming Alert
                .alert("Enter waypoint name",
                       isPresented: $showNamingAlert,
                       actions: {
                    TextField("BA2025, CSSU Lounge …", text: $newWaypointName)
                    
                    Button("Cancel", role: .cancel) {
                        newWaypointName = ""
                        pendingOffset   = nil
                    }
                    
                    Button("Save") {
                        let planar = SIMD3<Float>(pendingOffset?.x ?? 0, pendingOffset?.y ?? 0, 0)
                        let neighbours = lastWaypointId.map { [$0: -planar] } ?? [:]
                        
                        let waypoint = Waypoint(
                            name: newWaypointName,
                            texts: ocrScanner.flushTexts(),
                            neighbors: neighbours
                        )
                        
                        waypoints.append(waypoint)
                        
                        // bidirectional edge to previous waypoint
                        if let lastId = lastWaypointId,
                           let idx = waypoints.firstIndex(where: { $0.id == lastId }) {
                            let backPlanar = SIMD3<Float>(planar.x, planar.y, 0)
                            waypoints[idx].neighbors[waypoint.id] = backPlanar
                        }
                        
                        lastWaypointId    = waypoint.id
                        lastSavedPosition = currentPosition
                        
                        newWaypointName = ""
                        pendingOffset   = nil
                    }
                },
                       message: {
                    Text("This label will appear in the graph and in the picker.")
                })
                
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(.all)
        
        
    }
}
