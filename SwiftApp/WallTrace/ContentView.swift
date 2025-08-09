import SwiftUI
import RealityKit
import ARKit
import CoreLocation

/// The main View of WallTrace. Has two modes:
///     - Data Collection
///     - Explore (for inference)
///     
struct ContentView: View {
    enum AppMode {
        case dataCollection
        case inference
    }
    
    @StateObject private var headingProvider = HeadingProvider()
    @State private var currentPosition: SIMD3<Float> = .zero
    @State private var lastWaypointPosition: SIMD3<Float>? = SIMD3<Float>.zero
    @State private var relativeOffset: SIMD3<Float>? = nil

    @State private var waypoints: [Waypoint] = []

    @State private var isScanningText = false
    @State private var appMode: AppMode = .dataCollection
    
    private var ocrScanner = OCRScanner()
    
    // States for inference
    @State private var inferedWaypoint: Int? = nil
    
    // States for Navigation
    @State private var destWaypointId: UUID? = nil
    @StateObject private var navigationManager = NavigationManager()
    
    // Arrow controllers for each mode
    @StateObject private var dataCollectionArrowController = ArrowController()
    @StateObject private var inferenceArrowController = ArrowController()
    
    @State var output: String = ""
    
    var body: some View{
        VStack{
            Picker("Mode", selection: $appMode) {
                Text("Data Collection").tag(AppMode.dataCollection)
                Text("Explore").tag(AppMode.inference)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top)
            .padding(.horizontal)
            
            switch appMode {
            case .dataCollection:
                DataCollectionView(
                    arView: ARViewContainer(
                        headingProvider: headingProvider,
                        onPositionUpdate: { newPosition in
                            currentPosition = newPosition

                            if let last = lastWaypointPosition {
                                relativeOffset = newPosition - last
                            } else {
                                relativeOffset = nil
                            }
                        },
                        ocrScanner: ocrScanner,
                        arrowController: dataCollectionArrowController,
                        navigationManager: navigationManager // Still need to pass it even if not used
                    ),
                    ocrScanner: ocrScanner,
                    onResetWaypoints: resetWaypoints,
                    relativeOffset: $relativeOffset,
                    currentPosition: $currentPosition,
                    lastSavedPosition: $lastWaypointPosition,
                    isScanningText: $isScanningText,
                    waypoints: $waypoints
                )

            case .inference:
                InferenceView(
                    headingProvider: headingProvider,
                    ocrScanner: ocrScanner,
                    inferedWaypoint: $inferedWaypoint,
                    waypoints: $waypoints,
                    destWaypointId: $destWaypointId,
                    output: $output,
                    navigationManager: navigationManager
                )
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color("UofT Blue"))
        .onChange(of: appMode) {
            // Clear arrows when switching modes
            dataCollectionArrowController.removeAllArrows()
            inferenceArrowController.removeAllArrows()
        }
    }
    
    func resetWaypoints(){
        lastWaypointPosition = nil
        relativeOffset = nil
        waypoints.removeAll()
        isScanningText = false
        ocrScanner.stopScanning()
        
        // Reset navigation and clear arrows
        navigationManager.reset()
        dataCollectionArrowController.removeAllArrows()
        inferenceArrowController.removeAllArrows()
    }
}

#Preview {
    ContentView()
}
