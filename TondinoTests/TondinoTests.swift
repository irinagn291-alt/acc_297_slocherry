import XCTest
@testable import Tondino

final class TondinoTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: TondinoApp.self), "TondinoApp")
        XCTAssertEqual(Field.currentSchema, 1)
        XCTAssertEqual(FieldKey.snapshot, "tnd.field.v1")
        XCTAssertEqual(CatalogClient.userAgent, "Tondino/1.0 (iOS; +https://tondino-field.pro)")
    }
}
