import XCTest
@testable import Tondino

final class FieldJobTests: XCTestCase {
    func test_tondinoSchemeOpensFourDestinationsAndCutLodge() throws {
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://quiz"))), .quiz)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://explore"))), .explore)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://saved"))), .saved)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://settings"))), .settings)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://cut"))), .cut)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://lodge"))), .lodge)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://twist"))), .twist)
        XCTAssertNil(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://game"))))
        XCTAssertNil(try FieldJob.parse(XCTUnwrap(URL(string: "tondino://contact-us"))))
        XCTAssertNil(FieldJob.quiz.cover)
        XCTAssertNil(FieldJob.cut.cover)
        XCTAssertNil(FieldJob.lodge.cover)
        XCTAssertEqual(FieldJob.explore.cover, .explore)
        XCTAssertEqual(FieldJob.saved.cover, .saved)
        XCTAssertEqual(FieldJob.settings.cover, .settings)
        XCTAssertEqual(FieldJob.twist.cover, .twist)
        XCTAssertEqual(FieldCover.twist.rawValue, "twist")
        XCTAssertEqual(Set(FieldSheet.allCases.map(\.rawValue)).count, 4)
        XCTAssertFalse(FieldSheet.allCases.map(\.rawValue).contains("game"))
    }

    func test_httpsHostMapsTheSameJobs() throws {
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "https://tondino-field.pro/quiz"))), .quiz)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "https://tondino-field.pro/explore"))), .explore)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "https://tondino-field.pro/saved"))), .saved)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "https://tondino-field.pro/settings"))), .settings)
        XCTAssertEqual(try FieldJob.parse(XCTUnwrap(URL(string: "https://tondino-field.pro"))), .quiz)
        XCTAssertNil(try FieldJob.parse(XCTUnwrap(URL(string: "https://tondino-field.pro/contact-us"))))
        XCTAssertNil(try FieldJob.parse(XCTUnwrap(URL(string: "https://example.com/quiz"))))
    }

    func test_notificationParsesJobOnce() {
        let notice = Notification(
            name: .fieldJob,
            object: nil,
            userInfo: [FieldPost.key: FieldJob.saved.rawValue]
        )
        XCTAssertEqual(FieldJob.parse(notification: notice), .saved)
        XCTAssertNil(FieldJob.parse(notification: Notification(name: .fieldJob)))
    }

    func test_reviewHookMapsToFourDistinctSheets() {
        XCTAssertEqual(ReviewHook.today.sheet, .quiz)
        XCTAssertEqual(ReviewHook.log.sheet, .saved)
        XCTAssertEqual(ReviewHook.goals.sheet, .settings)
        XCTAssertEqual(ReviewHook.explore.sheet, .explore)
        XCTAssertNotEqual(ReviewHook.today.sheet, ReviewHook.log.sheet)
        XCTAssertNotEqual(ReviewHook.log.sheet, ReviewHook.goals.sheet)
        XCTAssertNotEqual(ReviewHook.today.sheet, ReviewHook.goals.sheet)
    }

    func test_figuresGoThroughNumberFormatter() {
        XCTAssertFalse(FieldFigures.whole(2).isEmpty)
        XCTAssertFalse(FieldFigures.daykey(20260918).isEmpty)
        XCTAssertEqual(FieldStatusInk.stamp(.idle), "Waiting")
        XCTAssertEqual(FieldStatusInk.stamp(.cut), "Crop ready")
        XCTAssertEqual(FieldStatusInk.stamp(.lodged), "Filed")
        XCTAssertEqual(FieldStatusInk.stamp(.chip), "Missed")
        XCTAssertEqual(FieldCopy.nextTap(status: .cut, canCut: false), "Tap the panel that owns this excerpt.")
        XCTAssertEqual(FieldCopy.nextTap(status: .lodged, canCut: true), "Filed. Cut the next tondo.")
        XCTAssertEqual(FieldCopy.nextTap(status: .idle, canCut: false), FieldCopy.gapLine)
        XCTAssertEqual(FieldCopy.gapHeadline, "Field waiting.")
        XCTAssertEqual(FieldCopy.gapLine, "Save four works, then cut.")
        XCTAssertEqual(FieldCopy.lodgeLine(status: .cut, canCut: false), "Lodge this tondo")
        XCTAssertEqual(FieldCopy.fault(TondoFault.lodgeOnIdle), "Cut a tondo first. Lodge is refused.")
        XCTAssertEqual(FieldCopy.fault(TondoFault.alreadyCut), "A shard is live. Lodge it first.")
        XCTAssertEqual(FieldCurve.card, 20)
        XCTAssertEqual(FieldCurve.chip, 12)
        XCTAssertEqual(FieldPad.unit, 8)
        XCTAssertEqual(FieldPad.hit, 44)
        XCTAssertEqual(FieldPad.outer, 24)
        XCTAssertEqual(FieldPad.card, 16)
        XCTAssertEqual(FieldFace.face, "SF Pro")
    }

    func test_chromeDoesNotHostAView() {
        XCTAssertEqual(String(describing: FieldChrome.self), "FieldChrome")
        XCTAssertEqual(String(describing: FieldJob.self), "FieldJob")
        XCTAssertEqual(FieldLinks.flag, "-ReviewScreen")
        XCTAssertEqual(FieldJob.httpsHost, "tondino-field.pro")
    }
}
