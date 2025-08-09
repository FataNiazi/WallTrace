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
    let relativeOffset: SIMD3<Float>?

    var body: some View {
        VStack(alignment: .center, spacing: 12) {

            if let offset = relativeOffset {
                Text("Δ from last:")
                ZStack{
                    // keep layout width stable
                    Text("E: +000.00, N: +000.00")
                        .monospaced()
                        .opacity(0)

                    Text(String(format: "E: %.2f, N: %.2f", offset.x, offset.y))
                        .monospaced()
                        .foregroundColor(.green)
                }

            }
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
