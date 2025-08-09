import Foundation
import simd

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

