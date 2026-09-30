import XCTest
@testable import Tondino

final class TondoFoldTests: XCTestCase {
    private var calendar: Calendar { TondinoGMT.calendar }
    private var now: Date { TondinoGMT.instant(2026, 9, 18) }
    private var caster: LeadingDonorCast { LeadingDonorCast() }
    private var shelf: [CatalogRow] { GettyShelf.bundled.rows }

    func test_architecture_notLodgedSampling_fourGroundsWithDonor_lodgeOnIdleRefuse_cutWhileCutRefuse_underFourIdle_missKeep_undoFoldBack_duplicateFocus() throws {
        var field = Field.empty
        XCTAssertEqual(foldLabel(field.tondo), "idle")

        for row in shelf.prefix(3) {
            _ = try field.stowLoose(row, now: now, calendar: calendar)
        }
        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        XCTAssertEqual(field.tondo, .idle)
        XCTAssertEqual(field.status, .idle)

        _ = try field.stowLoose(shelf[3], now: now, calendar: calendar)
        _ = try field.stowLoose(shelf[4], now: now, calendar: calendar)
        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        XCTAssertEqual(foldLabel(field.tondo), "cut")
        XCTAssertEqual(field.tondo.card?.grounds.count, 4)
        XCTAssertEqual(field.tondo.card?.grounds.filter(\.isDonor).count, 1)
        XCTAssertEqual(field.tondo.card?.grounds.filter { !$0.isDonor }.count, 3)
        XCTAssertEqual(field.tondo.card?.donorGround?.workID, field.tondo.donorWorkID)
        XCTAssertEqual(field.hangingDonor?.role, .loose)

        XCTAssertThrowsError(try field.cutTondo(now: now, calendar: calendar, caster: caster)) { error in
            XCTAssertEqual(error as? TondoFault, .alreadyCut)
        }
        XCTAssertEqual(foldLabel(field.tondo), "cut")

        let donorID = try XCTUnwrap(field.tondo.donorWorkID)
        let decoy = try XCTUnwrap(field.tondo.card?.grounds.first { !$0.isDonor })
        try field.chipGround(decoy.id, now: now, calendar: calendar)
        XCTAssertEqual(field.tondo.donorWorkID, donorID)
        XCTAssertEqual(foldLabel(field.tondo), "cut")
        XCTAssertEqual(field.status, .chip)
        XCTAssertEqual(field.reviewableChips.first?.groundID, decoy.id)
        XCTAssertTrue(field.tondo.card?.grounds.contains { $0.id == decoy.id && $0.isCooled && $0.isStruck } ?? false)
        XCTAssertEqual(field.hangingDonor?.role, .loose)

        let match = try XCTUnwrap(field.tondo.card?.grounds.first { $0.isDonor })
        _ = try field.lodgeGround(match.id, now: now, calendar: calendar)
        XCTAssertEqual(foldLabel(field.tondo), "lodged")
        XCTAssertEqual(field.hangingDonor?.role, .lodged)
        XCTAssertEqual(field.lodgeMarks.count, 1)
        XCTAssertFalse(field.cutPool.contains { $0.id == donorID })

        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        XCTAssertEqual(foldLabel(field.tondo), "cut")
        XCTAssertNotEqual(field.tondo.donorWorkID, donorID)

        let again = try field.stowLoose(shelf[0], now: now, calendar: calendar)
        guard case .focused(let focusedID) = again else {
            return XCTFail("expected focus")
        }
        XCTAssertEqual(field.works.filter { $0.accession == shelf[0].accession }.count, 1)
        XCTAssertEqual(field.focusedWorkID, focusedID)
        XCTAssertEqual(foldLabel(field.tondo), "cut")
    }

    func test_primaryVerb_emptyPopulatedInvalid() throws {
        var empty = Field.empty
        try empty.cutTondo(now: now, calendar: calendar, caster: caster)
        XCTAssertEqual(empty.status, .idle)
        XCTAssertFalse(empty.canLodge)
        XCTAssertThrowsError(try empty.lodgeGround(UUID(), now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? TondoFault, .lodgeOnIdle)
        }
        XCTAssertThrowsError(try empty.chipGround(UUID(), now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? TondoFault, .chipOnIdle)
        }

        var field = try stockedAndCut(count: 4)
        XCTAssertTrue(field.canLodge)
        XCTAssertEqual(field.status, .cut)
        XCTAssertEqual(field.tondo.card?.grounds.count, 4)

        XCTAssertThrowsError(try field.lodgeGround(UUID(), now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? TondoFault, .unknownGround)
        }
        let match = try XCTUnwrap(field.tondo.card?.grounds.first { $0.isDonor })
        XCTAssertThrowsError(try field.chipGround(match.id, now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? TondoFault, .chipOnDonor)
        }
        XCTAssertThrowsError(try field.liftLastMark()) { error in
            XCTAssertEqual(error as? TondoFault, .nothingToLift)
        }
        let decoy = try XCTUnwrap(field.tondo.card?.grounds.first { !$0.isDonor })
        XCTAssertThrowsError(try field.lodgeGround(decoy.id, now: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? TondoFault, .groundIsDecoy)
        }
    }

    func test_twist_cutThenLodge_undoLodgeRestoresCut_undoChipReheats() throws {
        var field = Field.empty
        for row in shelf.prefix(4) {
            _ = try field.stowLoose(row, now: now, calendar: calendar)
        }
        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        XCTAssertEqual(field.tondo.card?.grounds.filter(\.isDonor).count, 1)
        XCTAssertEqual(field.tondo.card?.grounds.count, 4)

        let decoy = try XCTUnwrap(field.tondo.card?.grounds.first { !$0.isDonor })
        let shardBefore = field.tondo.card?.shard
        try field.chipGround(decoy.id, now: now, calendar: calendar)
        XCTAssertEqual(field.tondo.card?.shard, shardBefore)
        XCTAssertEqual(field.status, .chip)

        try field.liftLastMark()
        XCTAssertEqual(field.reviewableChips.count, 0)
        XCTAssertEqual(field.tondo.card?.grounds.first { $0.id == decoy.id }?.isCooled, false)
        XCTAssertEqual(field.status, .cut)

        let savedCard = try XCTUnwrap(field.tondo.card)
        let match = try XCTUnwrap(field.tondo.card?.grounds.first { $0.isDonor })
        _ = try field.lodgeGround(match.id, now: now, calendar: calendar)
        XCTAssertEqual(foldLabel(field.tondo), "lodged")

        try field.liftLastMark()
        XCTAssertEqual(foldLabel(field.tondo), "cut")
        XCTAssertEqual(field.hangingDonor?.role, .loose)
        XCTAssertEqual(field.tondo.card?.shard.workID, savedCard.shard.workID)
        XCTAssertEqual(field.tondo.card?.grounds.map(\.workID), savedCard.grounds.map(\.workID))
        XCTAssertEqual(field.lodgeMarks.count, 0)
        XCTAssertTrue(field.canLodge)
    }

    func test_seedPunchesTondoAndEnablesLodge() {
        let field = FieldSeed.field(now: now, calendar: calendar, caster: caster, shelf: shelf)
        XCTAssertTrue(field.onboardingComplete)
        XCTAssertTrue(field.canLodge)
        XCTAssertEqual(foldLabel(field.tondo), "cut")
        XCTAssertEqual(field.tondo.card?.grounds.count, 4)
        XCTAssertEqual(field.hangingDonor?.role, .loose)
        XCTAssertGreaterThanOrEqual(field.works.count, 6)
        XCTAssertGreaterThanOrEqual(field.cutPool.count, 4)
        XCTAssertGreaterThanOrEqual(field.lodgeMarks.count, 2)
        XCTAssertGreaterThanOrEqual(field.reviewableChips.count, 3)
        XCTAssertNotEqual(field.status, .idle)
        XCTAssertFalse(field.canCut)
        for mark in field.reviewableChips {
            XCTAssertNotNil(field.work(mark.workID))
        }
    }

    func test_daykeyIsYYYYMMDDFromStartOfDay() {
        let late = TondinoGMT.instant(2026, 9, 18, hour: 23)
        let next = TondinoGMT.instant(2026, 9, 19, hour: 1)
        XCTAssertEqual(DayStamp.stamp(late, calendar: calendar), 20260918)
        XCTAssertEqual(DayStamp.stamp(next, calendar: calendar), 20260919)
        XCTAssertEqual(DayStamp.shifting(20260918, by: -1, calendar: calendar), 20260917)
    }

    func test_cutSamplesOnlyLooseWorks() throws {
        var field = Field.empty
        for row in shelf.prefix(4) {
            _ = try field.stowLoose(row, now: now, calendar: calendar)
        }
        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        let match = try XCTUnwrap(field.tondo.card?.grounds.first { $0.isDonor })
        _ = try field.lodgeGround(match.id, now: now, calendar: calendar)
        let lodgedID = try XCTUnwrap(field.tondo.donorWorkID)

        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        XCTAssertNotEqual(field.tondo.donorWorkID, lodgedID)
        XCTAssertEqual(field.hangingDonor?.role, .loose)
        XCTAssertTrue(field.lodgedWorks.contains { $0.id == lodgedID })
    }

    private func stockedAndCut(count: Int) throws -> Field {
        var field = Field.empty
        for row in shelf.prefix(count) {
            _ = try field.stowLoose(row, now: now, calendar: calendar)
        }
        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        return field
    }

    private func foldLabel(_ tondo: Tondo) -> String {
        switch tondo {
        case .idle:
            return "idle"
        case .cut:
            return "cut"
        case .lodged:
            return "lodged"
        }
    }
}
