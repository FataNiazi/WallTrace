
import SwiftUI

/// The View responsible for the users to explore and navigate
struct InferenceView: View{
    @StateObject private var arrowController = ArrowController()
    let headingProvider: HeadingProvider
    let ocrScanner: OCRScanner
    
    @Binding var inferedWaypoint: Int?
    @State var searchText: String=""
    @State private var showSearchSheet = false
    @Binding var waypoints: [Waypoint]
    
    @Binding var destWaypointId: UUID?
    
    @Binding var output: String
    
    @ObservedObject var navigationManager: NavigationManager
    
    var body: some View{
        
        ZStack {
            ARViewContainer(
                headingProvider: headingProvider,
                onPositionUpdate: { position in
                    // Position updates are handled in ARViewContainer now
                },
                ocrScanner: ocrScanner,
                arrowController: arrowController,
                navigationManager: navigationManager
            )
            .edgesIgnoringSafeArea(.all)
            .aspectRatio(9 / 16, contentMode: .fit)
            .padding(.vertical, 8)

            VStack {
                Spacer()

                ZStack {
                    Text("----------------------")
                        .monospaced()
                        .opacity(0)
                    Text(output)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(12)

                Spacer()

                SearchTriggerButton {
                    showSearchSheet = true
                }
            }
        }
        .onReceive(navigationManager.$remainingOffset) { offset in
            if let d = offset {
                // Only show ENU x,y
                output = String(format: "Remaining (E,N): (%.2f, %.2f)", d.x, d.y)
            } else if !navigationManager.path.isEmpty {
                output = "🎉 You've reached the destination!"
            } else {
                output = ""
            }
        }


        .sheet(isPresented: $showSearchSheet) {
            WaypointSearchSheet(
                isPresented: $showSearchSheet,
                waypoints: $waypoints,
                onSelection: { selectedId in
                    if let currentId = waypoints.first?.id,
                       let path = Navigation.findPath(from: currentId, to: selectedId, in: waypoints) {

                        navigationManager.startPath(path, waypoints: waypoints)
                        destWaypointId = selectedId

                    } else {
                        output = "❌ Could not determine current location."
                    }
                }
            )
        }
        
        
    }
    
}

struct SearchTriggerButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                Text("Search …")
                    .foregroundColor(.gray)
                    .font(.body)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
        }
        .padding(.horizontal)
    }
}

struct WaypointSearchSheet: View {
    @Binding var isPresented: Bool
    @Binding var waypoints: [Waypoint]
    
    @State private var searchText: String = ""
    
    let onSelection: (UUID) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search a place...", text: $searchText)
                    .safeAreaPadding(.all, 4)
                    .padding([.leading, .trailing], 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
            .padding()

            // Filtered, unique texts with UUID
            List(uniqueResults, id: \.text) { result in
                Button(action: {
                    // Handle selection - e.g., move AR to the waypoint
                    onSelection(result.id)
                    isPresented = false
                }) {
                    Text(result.text)
                }
            }
        }
        .presentationDetents([.fraction(0.3), .large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
    }

    // Derived filtered entries: unique texts with their corresponding waypoint UUID
    var uniqueResults: [(text: String, id: UUID)] {
        var seen = Set<String>()
        var results: [(String, UUID)] = []

        for wp in waypoints {
            for txt in wp.texts {
                guard !searchText.isEmpty
                      ? txt.localizedCaseInsensitiveContains(searchText)
                      : true
                else { continue }
                if !seen.contains(txt) {
                    seen.insert(txt)
                    results.append((txt, wp.id))
                }
            }
        }
        return results
    }
}
