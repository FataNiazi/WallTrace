//
//  PrevWaypointInfoView.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-02.
//

import Foundation
import SwiftUI
import SwiftUICore
import CoreML


struct PrevWaypointInfoView: View {
    
    let currentPosition: SIMD3<Float>
    let relativeOffset: SIMD3<Float>?

    let onRecord: () -> Void
    let onScan: () -> Void
    let onExport: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Current (North-aligned):")
                .multilineTextAlignment(.center)
            
            ZStack{
                // To avoid wiggling when there is a - sign
                Text("x: +000.00, y: 000.00, z: 000.00")
                    .monospaced()
                    .opacity(0)
                
                
                Text(String(format: "x: %.2f, y: %.2f, z: %.2f", currentPosition.x, currentPosition.y, currentPosition.z))
                    .monospaced()
                    .foregroundColor(.white)
            }

            if let offset = relativeOffset {
                Text("Δ from last:")
                ZStack{
                    // To avoid wiggling when there is a - sign
                    Text("x: +000.00, y: 000.00, z: 000.00")
                        .monospaced()
                        .opacity(0)
                    
                    Text(String(format: "dx: %.2f, dy: %.2f, dz: %.2f", offset.x, offset.y, offset.z))
                        .monospaced()
                        .foregroundColor(.green)
                }
            }

            Button("Record & Reset Waypoint", action: onRecord)
                .styledButton(background: .blue)

            Button("Start Scan", action: onScan)

            Button("Export Waypoints to JSON", action: onExport)
                .styledButton(background: .green)
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
        .padding()
    }
    
}

extension View {
    func styledButton(background: Color) -> some View {
        self
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(background.opacity(0.8))
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}
