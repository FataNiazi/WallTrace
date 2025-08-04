//
//  ControlView.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-02.
//
import SwiftUI

struct ControlView: View {
    let isScanning: Bool
    let scanAction: () -> Void
    let saveWaypointAction: () -> Void
    let resetRelativePosAction: () -> Void
    
    @State private var showRecorededWaypoints = false
    let lastWaypointOptions: [Int]
    @Binding var lastWaypointID: Int?
    
    
    var body: some View{
        ZStack {
            // Scan and Save Waypoint Buttons
            PillButtons(showScanButton: !isScanning, scanAction: scanAction, saveWaypointAction: saveWaypointAction)
                .padding(.vertical, 10)
            
            HStack{
                // Reset Location Button
                Button(action: resetRelativePosAction) {
                    Image(systemName: "graph.3d")
                        .imageScale(Image.Scale.large)
                        .symbolEffect(.bounce.down.byLayer, options: .nonRepeating)
                        .frame(width: 50, height: 50)
                        .background(Color.gray)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Select last Waypoint ID
                ScrollableNumberPicker(options: lastWaypointOptions, selected: $lastWaypointID)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.black.opacity(0.3))
        .frame(maxWidth: .infinity)
    }
}
    
struct PillButtons: View {
    let showScanButton: Bool
    let scanAction: () -> Void
    let saveWaypointAction: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            
            if showScanButton {
                Button(action: {
                    scanAction()
                }) {
                    Image(systemName: "text.viewfinder")
                        .imageScale(Image.Scale.large)
                        .frame(width: 100, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(
                            Capsule()
                        )
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
            
            Button(action: {
                saveWaypointAction()
            }) {
                Image(systemName: "mappin.and.ellipse.circle.fill")
                    .imageScale(Image.Scale.large)
                    .frame(
                        width: showScanButton ? 100 : 200,
                        height: 80
                    )
                    .background(showScanButton ? Color.blue : Color.green)
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showScanButton)
    }
}
    
struct BottomSliderMenu: View {
    var options: [Int]
    @Binding var selected: Int?
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose an option")
                .font(.headline)
            
            Picker("Options", selection: $selected) {
                ForEach(options, id: \.self) { option in
                    Text("\(option)").tag(Optional(option))
                }
            }
            .pickerStyle(.wheel) // or use .inline for compact
            .labelsHidden()
            
            Button("Done") {
                isPresented = false
            }
            .padding(.top, 10)
        }
        .padding()
        .presentationDetents([.fraction(0.3), .fraction(0.5)])
        .presentationDragIndicator(.visible)
    }
}

struct ScrollableNumberPicker: View {
    let options: [Int]
    @Binding var selected: Int?

    @GestureState private var dragOffset: CGFloat = 0
    @State private var internalSelectedIndex: Int = 0

    var body: some View {
        let dragGesture = DragGesture(minimumDistance: 5)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                let threshold: CGFloat = 20
                let direction = value.translation.height < 0 ? -1 : 1
                let shouldChange = abs(value.translation.height) > threshold

                if shouldChange {
                    let nextIndex = internalSelectedIndex + direction
                    if options.indices.contains(nextIndex) {
                        internalSelectedIndex = nextIndex
                        selected = options[internalSelectedIndex]
                    }
                }
            }

        Button(action: {}) {
            ZStack {
                // Placeholder for stable size
                Text("000")
                    .monospaced()
                    .opacity(0)

                if let current = selected {
                    Text("\(current)")
                        .monospaced()
                        .font(.title)
                        .foregroundColor(.white)
                        .transition(.opacity)
                        .id(current) // triggers animation
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.blue)
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.2), value: selected)
        }
        .simultaneousGesture(dragGesture)
        .onAppear {
            if let selected = selected,
               let idx = options.firstIndex(of: selected) {
                internalSelectedIndex = idx
            } else if let first = options.first {
                selected = first
                internalSelectedIndex = 0
            }
        }
    }
}

