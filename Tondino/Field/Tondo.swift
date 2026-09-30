import Foundation

/// Role: Tondo. Closed algebraic fold Idle | Cut | Lodged. A fourth case is a defect. Chip is a Cut overlay.
enum Tondo: Equatable, Sendable {
    case idle
    case cut(TondoCard)
    case lodged(TondoCard, lodgeMarkID: UUID)

    var card: TondoCard? {
        switch self {
        case .idle:
            return nil
        case .cut(let card), .lodged(let card, _):
            return card
        }
    }

    var donorWorkID: UUID? {
        card?.shard.workID
    }

    var status: TondoStatus {
        switch self {
        case .idle:
            return .idle
        case .cut(let card):
            return card.hasChip ? .chip : .cut
        case .lodged:
            return .lodged
        }
    }
}

extension Tondo: Codable {
    enum Kind: String, Codable, Sendable {
        case idle
        case cut
        case lodged
    }

    private enum CodingKeys: String, CodingKey {
        case kind
        case card
        case lodgeMarkID
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .idle:
            try container.encode(Kind.idle, forKey: .kind)
        case .cut(let card):
            try container.encode(Kind.cut, forKey: .kind)
            try container.encode(card, forKey: .card)
        case .lodged(let card, let lodgeMarkID):
            try container.encode(Kind.lodged, forKey: .kind)
            try container.encode(card, forKey: .card)
            try container.encode(lodgeMarkID, forKey: .lodgeMarkID)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .idle:
            self = .idle
        case .cut:
            self = .cut(try container.decode(TondoCard.self, forKey: .card))
        case .lodged:
            let card = try container.decode(TondoCard.self, forKey: .card)
            let lodgeMarkID = try container.decode(UUID.self, forKey: .lodgeMarkID)
            self = .lodged(card, lodgeMarkID: lodgeMarkID)
        }
    }
}

/// Role: Tondo. QuizCard. One circular Shard plus four Grounds, one donor and three other saved Works.
struct TondoCard: Equatable, Sendable, Codable {
    var shard: Shard
    var grounds: [Ground]

    var hasChip: Bool {
        grounds.contains(where: \.isCooled)
    }

    var donorGround: Ground? {
        grounds.first(where: \.isDonor)
    }
}

/// Role: Tondo. Dock status. CHIP is a Cut overlay, not a fourth fold case.
enum TondoStatus: String, Sendable, Equatable {
    case idle
    case cut
    case lodged
    case chip
}

/// Role: Tondo. Typed refusals of Cut, Lodge, Chip, and Undo. Views map these.
enum TondoFault: Error, Equatable, Sendable {
    case alreadyCut
    case lodgeOnIdle
    case chipOnIdle
    case alreadyLodged
    case unknownGround
    case groundIsDecoy
    case chipOnDonor
    case groundSpent
    case nothingToLift
    case emptyAccession
}

/// Role: Tondo. Ordered peel stack. Undo pops the newest LodgeMark or ChipMark.
enum PeelKind: String, Codable, Sendable {
    case lodge
    case chip
}

struct PeelRef: Equatable, Sendable, Codable {
    var kind: PeelKind
    var markID: UUID
}

/// Role: Tondo. Explore save outcome. Duplicate accession focuses and does not reset the fold.
enum StowFocus: Equatable, Sendable {
    case inserted(UUID)
    case focused(UUID)
}

/// Role: Tondo. Recoverable load outcome. Never crash on a corrupt snapshot.
enum FieldWarning: Equatable, Sendable {
    case recoveredFromBackup
    case startedEmpty
}
