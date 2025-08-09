import Foundation
import simd

/// Represents a Waypoint in a building floor.
/// Attributes:
///     - name: the name of the Waypoint, can be repeated ( the id is unique and auto generated)
///     - texts: the texts in the surrounding area of the Waypoint
///     - neighbours: the Waypoints connected and their relative position. Waypoint IDs are keys
///     and their position relative to this Waypoint is the value.
///
class Waypoint: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    var texts: [String]
    var neighbors: [UUID: SIMD3<Float>]  // ID → relative offset (this → neighbor)

    
    init(name: String, texts: [String] = [], neighbors: [UUID: SIMD3<Float>] = [:]) {
        self.id = UUID()
        self.name = name
        self.texts = texts
        self.neighbors = neighbors
    }
    
    static func == (lhs: Waypoint, rhs: Waypoint) -> Bool {
            lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    
}

