import Foundation

/// Role: LodgeMark. A matching Lodge files the donor Ground. The Work leaves the cut pool as Lodged.
struct LodgeMark: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var workID: UUID
    var card: TondoCard
    var daykey: Int
}
