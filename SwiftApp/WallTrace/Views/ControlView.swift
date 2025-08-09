//
//  ControlView.swift
//  inUofT
//
//  Created by Fata Niazi on 2025-08-02.
//
import SwiftUI
import simd

/// Lightweight DTO that pairs a human‑readable name with its UUID.
struct WaypointSummary: Identifiable, Hashable {
    let id: UUID
    let name: String
}

struct ControlView: View {
    // MARK: – Inputs
    let isScanning: Bool
    let scanAction: () -> Void
    let saveWaypointAction: () -> Void
    let resetRelativePosAction: () -> Void

    /// List of available waypoints and their names for the picker.
    let waypointSummaries: [WaypointSummary]

    /// *Single* source‑of‑truth for whatever waypoint should be considered "last".
    @Binding var lastWaypointId: UUID?

    // MARK: – Local UI state
    @State private var showWaypointPicker = false

    var body: some View {
        ZStack {
            // Scan / Save buttons in the middle
            PillButtons(showScanButton: !isScanning,
                        scanAction: scanAction,
                        saveWaypointAction: saveWaypointAction)
                .padding(.vertical, 10)

            HStack {
                // ↺  Reset button
                Button(action: resetRelativePosAction) {
                    Image(systemName: "graph.3d")
                        .imageScale(.large)
                        .symbolEffect(.bounce.down.byLayer, options: .nonRepeating)
                        .frame(width: 50, height: 50)
                        .background(Color.gray)
                        .clipShape(Circle())
                }

                Spacer()

                // Picker for selecting what counts as the "last" waypoint
                WaypointPickerMenu(
                    options: waypointSummaries,
                    selectedId: $lastWaypointId,
                    isPresented: $showWaypointPicker
                )
            }
            .padding(.horizontal, 20)
        }
        .background(Color.black.opacity(0.3))
        .frame(maxWidth: .infinity)
        .safeAreaPadding(.bottom, 50)
    }
}

// MARK: – Sub‑views

/// Two‑button strip that animates between Scan+Save and single Save.
private struct PillButtons: View {
    let showScanButton: Bool
    let scanAction: () -> Void
    let saveWaypointAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            if showScanButton {
                Button(action: scanAction) {
                    Image(systemName: "text.viewfinder")
                        .imageScale(.large)
                        .frame(width: 100, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                }
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            Button(action: saveWaypointAction) {
                Image(systemName: "mappin.and.ellipse.circle.fill")
                    .imageScale(.large)
                    .frame(width: showScanButton ? 100 : 200, height: 80)
                    .background(showScanButton ? Color.blue : Color.green)
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showScanButton)
    }
}

/// Bottom sheet that lets the user choose which waypoint should be considered “last”.
private struct WaypointPickerMenu: View {
    let options: [WaypointSummary]
    @Binding var selectedId: UUID?
    @Binding var isPresented: Bool

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "list.bullet.circle")
                .imageScale(.large)
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
        .sheet(isPresented: $isPresented) {
            VStack(spacing: 20) {
                Text("Choose last waypoint")
                    .font(.headline)

                Picker("Waypoints", selection: $selectedId) {
                    ForEach(options) { wp in
                        Text(wp.name).tag(Optional(wp.id))
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()

                Button("Done") { isPresented = false }
                    .padding(.top, 10)
            }
            .padding()
            .presentationDetents([.fraction(0.3), .fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
    }
}
