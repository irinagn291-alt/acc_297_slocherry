import Foundation

/// Role: Ground. One full panel in the four-ground rail. The donor owns the live Shard.
struct Ground: Identifiable, Equatable, Sendable, Codable {
    var id: UUID
    var workID: UUID
    var isDonor: Bool
    var isCooled: Bool
    var isStruck: Bool

    static func live(id: UUID = UUID(), workID: UUID, isDonor: Bool) -> Ground {
        Ground(
            id: id,
            workID: workID,
            isDonor: isDonor,
            isCooled: false,
            isStruck: false
        )
    }
}

/// Role: Ground. Pins Ground order. Tests pin the donor first.
protocol RoundelCasting: Sendable {
    func arrange(_ grounds: [Ground], salt: Int) -> [Ground]
}

struct LeadingDonorCast: RoundelCasting {
    func arrange(_ grounds: [Ground], salt: Int) -> [Ground] {
        _ = salt
        return grounds.sorted { lhs, rhs in
            if lhs.isDonor != rhs.isDonor {
                return lhs.isDonor && !rhs.isDonor
            }
            return lhs.workID.uuidString < rhs.workID.uuidString
        }
    }
}

struct RotateRoundelCast: RoundelCasting {
    func arrange(_ grounds: [Ground], salt: Int) -> [Ground] {
        guard grounds.count > 1 else { return grounds }
        var shift = abs(salt) % grounds.count
        if shift == 0 {
            shift = 1
        }
        return Array(grounds[shift...]) + Array(grounds[..<shift])
    }
}

/// Role: Ground. Hangs four Grounds: the donor plus three other saved Works.
enum RoundelHang {
    static func card(
        donor: Work,
        saved: [Work],
        caster: any RoundelCasting,
        groundIDs: [UUID]? = nil,
        shardID: UUID = UUID()
    ) -> TondoCard {
        let others = saved
            .filter { $0.id != donor.id }
            .sorted { lhs, rhs in
                if lhs.daykey != rhs.daykey { return lhs.daykey < rhs.daykey }
                if lhs.accession != rhs.accession { return lhs.accession < rhs.accession }
                return lhs.id.uuidString < rhs.id.uuidString
            }
            .prefix(3)
        var grounds = [Ground.live(workID: donor.id, isDonor: true)]
        grounds.append(contentsOf: others.map { Ground.live(workID: $0.id, isDonor: false) })
        if let groundIDs, groundIDs.count >= grounds.count {
            for index in grounds.indices {
                grounds[index].id = groundIDs[index]
            }
        }
        let salt = saltValue(donor.id)
        grounds = caster.arrange(grounds, salt: salt)
        return TondoCard(
            shard: Shard.punch(from: donor.id, id: shardID),
            grounds: grounds
        )
    }

    private static func saltValue(_ id: UUID) -> Int {
        var hasher = Hasher()
        hasher.combine(id)
        return hasher.finalize()
    }
}
