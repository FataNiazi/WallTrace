//
//  Menu.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-03.
//

import SwiftUI

struct MoreMenuButton: View {
    let onExport: () -> Void
    let onResetWaypoints: () -> Void
    
    var body: some View {
        Menu {
            Button("Export JSON", action: handleExport)
            Button("Reset Waypoints", role: .destructive, action: handleResetWaypoints)
        } label: {
            Image(systemName: "ellipsis")
                .imageScale(.large)
                .padding()
        }
    }

    func handleExport() {
        onExport()
    }

    func handleResetWaypoints() {
        onResetWaypoints()
    }
}
