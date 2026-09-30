import Foundation

/// Role: Shard. Circular excerpt punched from a Loose donor. The hoop never leaves Quiz.
struct Shard: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var workID: UUID
    var focusX: Double
    var focusY: Double
    var hoop: Double

    static func punch(from workID: UUID, id: UUID = UUID()) -> Shard {
        let salt = Self.salt(workID)
        let span = Double((abs(salt) % 21) + 10) / 100
        let side = salt >= 0
        return Shard(
            id: id,
            workID: workID,
            focusX: side ? 0.38 + span * 0.4 : 0.62 - span * 0.4,
            focusY: 0.42 + Double(abs(salt / 3) % 17) / 100,
            hoop: 0.22 + Double(abs(salt / 5) % 7) / 100
        )
    }

    private static func salt(_ id: UUID) -> Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }
}
