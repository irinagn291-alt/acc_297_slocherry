import Foundation

/// Role: Field. In-memory fold over Works. Views call cutTondo, lodgeGround, chipGround, and liftLastMark. Never a second role enum. Colour tokens live in Assets.xcassets. SF Pro is the system face.
struct Field: Equatable, Sendable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var works: [Work]
    var tondo: Tondo
    var lodgeMarks: [LodgeMark]
    var chipMarks: [ChipMark]
    var peelLog: [PeelRef]
    var cachedRows: [CatalogRow]
    var focusedWorkID: UUID?

    static let currentSchema = 1

    static let empty = Field(
        schemaVersion: currentSchema,
        onboardingComplete: false,
        works: [],
        tondo: .idle,
        lodgeMarks: [],
        chipMarks: [],
        peelLog: [],
        cachedRows: [],
        focusedWorkID: nil
    )

    var cutPool: [Work] {
        works.filter { $0.role == .loose }
    }

    var lodgedWorks: [Work] {
        works.filter { $0.role == .lodged }
    }

    var reviewableChips: [ChipMark] {
        chipMarks
    }

    var canCut: Bool {
        if case .cut = tondo { return false }
        return works.count >= 4 && !cutPool.isEmpty
    }

    var canLodge: Bool {
        if case .cut = tondo { return true }
        return false
    }

    var status: TondoStatus {
        tondo.status
    }

    var hangingDonor: Work? {
        guard let id = tondo.donorWorkID else { return nil }
        return work(id)
    }

    func work(_ id: UUID) -> Work? {
        works.first { $0.id == id }
    }

    mutating func cutTondo(
        now: Date,
        calendar: Calendar,
        caster: any RoundelCasting,
        groundIDs: [UUID]? = nil,
        shardID: UUID = UUID()
    ) throws {
        _ = now
        _ = calendar
        if case .cut = tondo {
            throw TondoFault.alreadyCut
        }
        guard works.count >= 4 else {
            tondo = .idle
            return
        }
        let pool = cutPool.sorted { lhs, rhs in
            if lhs.daykey != rhs.daykey { return lhs.daykey < rhs.daykey }
            if lhs.accession != rhs.accession { return lhs.accession < rhs.accession }
            return lhs.id.uuidString < rhs.id.uuidString
        }
        guard let chosen = pool.first(where: { $0.id != tondo.donorWorkID }) ?? pool.first else {
            tondo = .idle
            return
        }
        let card = RoundelHang.card(
            donor: chosen,
            saved: works,
            caster: caster,
            groundIDs: groundIDs,
            shardID: shardID
        )
        tondo = .cut(card)
        focusedWorkID = chosen.id
    }

    @discardableResult
    mutating func lodgeGround(
        _ groundID: UUID,
        markID: UUID = UUID(),
        now: Date,
        calendar: Calendar
    ) throws -> LodgeMark {
        guard case .cut(let card) = tondo else {
            if case .lodged = tondo { throw TondoFault.alreadyLodged }
            throw TondoFault.lodgeOnIdle
        }
        guard let ground = card.grounds.first(where: { $0.id == groundID }) else {
            throw TondoFault.unknownGround
        }
        guard ground.isDonor else { throw TondoFault.groundIsDecoy }
        guard let workIndex = works.firstIndex(where: { $0.id == card.shard.workID }) else {
            throw TondoFault.unknownGround
        }
        works[workIndex].role = .lodged
        let mark = LodgeMark(
            id: markID,
            workID: card.shard.workID,
            card: card,
            daykey: DayStamp.stamp(now, calendar: calendar)
        )
        lodgeMarks.append(mark)
        peelLog.append(PeelRef(kind: .lodge, markID: markID))
        tondo = .lodged(card, lodgeMarkID: mark.id)
        focusedWorkID = mark.workID
        return mark
    }

    mutating func chipGround(
        _ groundID: UUID,
        markID: UUID = UUID(),
        now: Date,
        calendar: Calendar
    ) throws {
        guard case .cut(var card) = tondo else {
            if case .lodged = tondo { throw TondoFault.alreadyLodged }
            throw TondoFault.chipOnIdle
        }
        guard let index = card.grounds.firstIndex(where: { $0.id == groundID }) else {
            throw TondoFault.unknownGround
        }
        if card.grounds[index].isDonor { throw TondoFault.chipOnDonor }
        if card.grounds[index].isCooled { throw TondoFault.groundSpent }
        card.grounds[index].isCooled = true
        card.grounds[index].isStruck = true
        let mark = ChipMark(
            id: markID,
            workID: card.shard.workID,
            groundID: groundID,
            daykey: DayStamp.stamp(now, calendar: calendar)
        )
        chipMarks.append(mark)
        peelLog.append(PeelRef(kind: .chip, markID: markID))
        tondo = .cut(card)
    }

    mutating func liftLastMark() throws {
        guard let last = peelLog.popLast() else { throw TondoFault.nothingToLift }
        switch last.kind {
        case .lodge:
            peelLodge(markID: last.markID)
        case .chip:
            peelChip(markID: last.markID)
        }
    }

    @discardableResult
    mutating func stowLoose(
        _ row: CatalogRow,
        now: Date,
        calendar: Calendar,
        id: UUID = UUID()
    ) throws -> StowFocus {
        let accession = row.accession.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !accession.isEmpty else { throw TondoFault.emptyAccession }
        if let existing = works.first(where: { $0.accession == accession }) {
            focusedWorkID = existing.id
            return .focused(existing.id)
        }
        var incoming = row
        incoming.accession = accession
        incoming.maker = row.maker.trimmingCharacters(in: .whitespacesAndNewlines)
        incoming.title = row.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let work = Work.loose(from: incoming, id: id, daykey: DayStamp.stamp(now, calendar: calendar))
        works.append(work)
        remember(incoming)
        focusedWorkID = work.id
        return .inserted(work.id)
    }

    mutating func remember(_ rows: [CatalogRow]) {
        for row in rows {
            remember(row)
        }
    }

    mutating func remember(_ row: CatalogRow) {
        let accession = row.accession.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !accession.isEmpty else { return }
        var stored = row
        stored.accession = accession
        stored.maker = row.maker.trimmingCharacters(in: .whitespacesAndNewlines)
        stored.title = row.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let index = cachedRows.firstIndex(where: { $0.accession == stored.accession }) {
            cachedRows[index] = stored
        } else {
            cachedRows.append(stored)
        }
    }

    mutating func setOnboardingComplete(_ flag: Bool) {
        onboardingComplete = flag
    }

    mutating func resetAllData() {
        self = .empty
    }

    func fallbackRows(shelf: [CatalogRow]) -> [CatalogRow] {
        var seen = Set<String>()
        var merged: [CatalogRow] = []
        for row in cachedRows + shelf {
            if seen.insert(row.accession).inserted {
                merged.append(row)
            }
        }
        return merged
    }

    private mutating func peelLodge(markID: UUID) {
        guard let index = lodgeMarks.firstIndex(where: { $0.id == markID }) else { return }
        let mark = lodgeMarks.remove(at: index)
        if let workIndex = works.firstIndex(where: { $0.id == mark.workID }) {
            works[workIndex].role = .loose
        }
        tondo = .cut(mark.card)
        focusedWorkID = mark.workID
    }

    private mutating func peelChip(markID: UUID) {
        guard let index = chipMarks.firstIndex(where: { $0.id == markID }) else { return }
        let mark = chipMarks.remove(at: index)
        switch tondo {
        case .idle:
            break
        case .cut(var card):
            reheat(groundID: mark.groundID, in: &card)
            tondo = .cut(card)
        case .lodged(var card, let lodgeMarkID):
            reheat(groundID: mark.groundID, in: &card)
            tondo = .lodged(card, lodgeMarkID: lodgeMarkID)
        }
    }

    private func reheat(groundID: UUID, in card: inout TondoCard) {
        guard let index = card.grounds.firstIndex(where: { $0.id == groundID }) else { return }
        card.grounds[index].isCooled = false
        card.grounds[index].isStruck = false
    }
}
