import Foundation

/// Role: ChipMark. A miss on a distractor Ground. The Shard stays. Reviewable on Saved.
struct ChipMark: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var workID: UUID
    var groundID: UUID
    var daykey: Int
}
