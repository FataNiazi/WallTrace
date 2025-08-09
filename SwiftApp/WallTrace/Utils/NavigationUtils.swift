import Foundation
import simd

struct Navigation {
    /// Returns the shortest path (as list of waypoint IDs) from start to destination using BFS
    static func findPath(
        from startId: UUID,
        to destId: UUID,
        in waypoints: [Waypoint]
    ) -> [UUID]? {
        let graph = Dictionary(uniqueKeysWithValues: waypoints.map { ($0.id, $0) })
        guard graph[startId] != nil && graph[destId] != nil else { return nil }

        var queue: [[UUID]] = [[startId]]
        var visited: Set<UUID> = [startId]

        while !queue.isEmpty {
            let path = queue.removeFirst()
            guard let last = path.last, let current = graph[last] else { continue }

            if last == destId {
                return path
            }

            for neighborId in current.neighbors.keys where !visited.contains(neighborId) {
                visited.insert(neighborId)
                queue.append(path + [neighborId])
            }
        }

        return nil // No path found
    }
}
