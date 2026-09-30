import XCTest
@testable import Tondino

/// Family invariant: Quiz draws from saved works. Misses are reviewable. Collecting without a test is the crate clone.
final class FamilyInvariantTests: XCTestCase {
    private var calendar: Calendar { TondinoGMT.calendar }
    private var now: Date { TondinoGMT.instant(2026, 9, 18) }
    private var caster: LeadingDonorCast { LeadingDonorCast() }
    private var shelf: [CatalogRow] { GettyShelf.bundled.rows }

    func test_quizDrawsFromSavedWorks_missesStayReviewable_stowingIsNotFiling() throws {
        var field = Field.empty
        XCTAssertFalse(field.canCut)
        XCTAssertFalse(field.canLodge)
        XCTAssertEqual(field.status, .idle)

        for row in shelf.prefix(4) {
            _ = try field.stowLoose(row, now: now, calendar: calendar)
        }
        XCTAssertEqual(field.works.count, 4)
        XCTAssertEqual(field.lodgedWorks.count, 0)
        XCTAssertEqual(field.cutPool.count, 4)
        XCTAssertEqual(field.tondo, .idle)

        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        let donorID = try XCTUnwrap(field.tondo.donorWorkID)
        XCTAssertTrue(field.cutPool.contains { $0.id == donorID })
        XCTAssertEqual(field.tondo.card?.grounds.count, 4)
        XCTAssertEqual(field.tondo.card?.grounds.filter(\.isDonor).count, 1)
        XCTAssertTrue(field.canLodge)
        let hungIDs = Set(field.tondo.card?.grounds.map(\.workID) ?? [])
        let savedIDs = Set(field.works.map(\.id))
        XCTAssertTrue(hungIDs.isSubset(of: savedIDs))

        let decoy = try XCTUnwrap(field.tondo.card?.grounds.first { !$0.isDonor })
        try field.chipGround(decoy.id, now: now, calendar: calendar)
        XCTAssertEqual(field.tondo.donorWorkID, donorID)
        XCTAssertEqual(field.hangingDonor?.role, .loose)
        XCTAssertEqual(field.reviewableChips.count, 1)
        XCTAssertEqual(field.reviewableChips.first?.workID, donorID)
        XCTAssertEqual(field.status, .chip)
        XCTAssertEqual(field.lodgedWorks.count, 0)
        XCTAssertTrue(field.cutPool.contains { $0.id == donorID })
    }

    func test_lodgedWorksLeaveTheCutPool() throws {
        var field = try stockedAndCut(count: 5)
        let firstDonor = try XCTUnwrap(field.tondo.donorWorkID)
        let match = try XCTUnwrap(field.tondo.card?.grounds.first { $0.isDonor })
        _ = try field.lodgeGround(match.id, now: now, calendar: calendar)
        XCTAssertEqual(field.hangingDonor?.role, .lodged)
        XCTAssertEqual(field.lodgedWorks.count, 1)
        XCTAssertFalse(field.cutPool.contains { $0.id == firstDonor })
        XCTAssertEqual(field.status, .lodged)

        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        XCTAssertNotEqual(field.tondo.donorWorkID, firstDonor)
        XCTAssertEqual(field.tondo.card?.grounds.count, 4)
        XCTAssertEqual(field.status, .cut)
        XCTAssertEqual(field.hangingDonor?.role, .loose)
    }

    private func stockedAndCut(count: Int) throws -> Field {
        var field = Field.empty
        for row in shelf.prefix(count) {
            _ = try field.stowLoose(row, now: now, calendar: calendar)
        }
        try field.cutTondo(now: now, calendar: calendar, caster: caster)
        return field
    }
}
