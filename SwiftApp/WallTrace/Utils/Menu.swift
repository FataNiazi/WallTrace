import SwiftUI

/// The View for the Menu to select between DataCollection and Explore mode.
/// 
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
