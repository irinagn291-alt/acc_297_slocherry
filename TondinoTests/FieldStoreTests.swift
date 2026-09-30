import XCTest
@testable import Tondino

final class FieldStoreTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var calendar: Calendar { TondinoGMT.calendar }
    private var now: Date { TondinoGMT.instant(2026, 9, 18) }

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        suiteName = "tnd.test.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        if let directory {
            try? FileManager.default.removeItem(at: directory)
        }
        if let suiteName {
            defaults?.removePersistentDomain(forName: suiteName)
        }
        directory = nil
        defaults = nil
        suiteName = nil
    }

    @MainActor
    func test_roundTrip_reloadPreservesTondoMarksAndWorkRole() async throws {
        let store = makeStore()
        await store.load()
        for row in GettyShelf.bundled.rows.prefix(4) {
            try await store.stowLoose(row, now: now, calendar: calendar)
        }
        try await store.cutTondo(now: now, calendar: calendar)
        let decoy = try XCTUnwrap(store.field.tondo.card?.grounds.first { !$0.isDonor })
        try await store.chipGround(decoy.id, now: now, calendar: calendar)
        let match = try XCTUnwrap(store.field.tondo.card?.grounds.first { $0.isDonor })
        try await store.lodgeGround(match.id, now: now, calendar: calendar)
        await store.flush()

        let relaunched = makeStore()
        await relaunched.load()
        XCTAssertNil(relaunched.warning)
        XCTAssertEqual(relaunched.field.works.count, 4)
        XCTAssertEqual(relaunched.field.hangingDonor?.role, .lodged)
        XCTAssertEqual(relaunched.field.lodgeMarks.count, 1)
        XCTAssertEqual(relaunched.field.chipMarks.count, 1)
        XCTAssertEqual(relaunched.field.status, .lodged)
        XCTAssertNotNil(defaults.data(forKey: FieldKey.snapshot))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("field.json").path))
        let lodgedness = relaunched.field.works.map(\.role)
        XCTAssertEqual(lodgedness.filter { $0 == .lodged }.count, 1)
    }

    @MainActor
    func test_corruptSnapshotFallsBackToBackup() async throws {
        let store = makeStore()
        await store.load()
        try await store.stowLoose(GettyShelf.bundled.rows[0], now: now, calendar: calendar)
        await store.flush()
        if let good = defaults.data(forKey: FieldKey.snapshot) {
            defaults.set(good, forKey: FieldKey.backup)
        }
        let file = directory.appendingPathComponent("field.json")
        let backup = directory.appendingPathComponent("field.json.backup")
        if FileManager.default.fileExists(atPath: file.path) {
            try? FileManager.default.removeItem(at: backup)
            try FileManager.default.copyItem(at: file, to: backup)
        }
        defaults.set(Data("{not-json".utf8), forKey: FieldKey.snapshot)
        try Data("{not-json".utf8).write(to: file)

        let loaded = makeStore()
        await loaded.load()
        XCTAssertEqual(loaded.warning, .recoveredFromBackup)
        XCTAssertEqual(loaded.field.works.count, 1)
    }

    @MainActor
    func test_corruptSnapshotWithoutBackupStartsEmpty() async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defaults.set(Data("nope".utf8), forKey: FieldKey.snapshot)
        try Data("nope".utf8).write(to: directory.appendingPathComponent("field.json"))
        let store = makeStore()
        await store.load()
        XCTAssertEqual(store.warning, .startedEmpty)
        XCTAssertTrue(store.field.works.isEmpty)
        XCTAssertFalse(store.field.onboardingComplete)
    }

    func test_codecSwitchesOnSchemaVersion() throws {
        let field = FieldSeed.field(now: now, calendar: calendar)
        let data = try FieldDocument.encode(field)
        let decoded = try FieldDocument.decode(data)
        XCTAssertEqual(decoded.schemaVersion, 1)
        XCTAssertEqual(decoded.works.count, field.works.count)
        XCTAssertEqual(decoded.tondo.donorWorkID, field.tondo.donorWorkID)
        XCTAssertEqual(decoded.chipMarks.count, field.chipMarks.count)
        XCTAssertTrue(decoded.works.contains { $0.role == .lodged })
        XCTAssertTrue(decoded.works.contains { $0.role == .loose })

        XCTAssertThrowsError(try FieldDocument.decode(Data("{\"schemaVersion\":99}".utf8))) { error in
            XCTAssertEqual(error as? FieldCodecError, .unsupportedSchema(99))
        }
        XCTAssertThrowsError(try FieldDocument.decode(Data("[]".utf8))) { error in
            XCTAssertEqual(error as? FieldCodecError, .corrupt)
        }
    }

    @MainActor
    func test_resetAllDataClearsSnapshotAndFiles() async throws {
        let store = makeStore()
        await store.load()
        try await store.stowLoose(GettyShelf.bundled.rows[0], now: now, calendar: calendar)
        await store.flush()
        await store.resetAllData()
        await store.load()
        XCTAssertTrue(store.field.works.isEmpty)
        XCTAssertFalse(store.field.onboardingComplete)
        XCTAssertNil(defaults.data(forKey: FieldKey.snapshot))
        XCTAssertNil(defaults.data(forKey: FieldKey.backup))
        let leftovers = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        XCTAssertTrue(leftovers.filter { $0.pathExtension == "json" }.isEmpty)
    }

    @MainActor
    func test_onboardingFlagDebouncesUntilFlush() async throws {
        let store = makeStore()
        await store.load()
        await store.setOnboardingComplete(true)
        await store.flush()
        let loaded = makeStore()
        await loaded.load()
        XCTAssertTrue(loaded.field.onboardingComplete)
    }

    #if targetEnvironment(simulator)
    @MainActor
    func test_simulatorSeedWritesOnceAndEnablesLodge() async throws {
        let store = makeStore()
        await store.seedDemoIfNeeded(now: now, calendar: calendar)
        let firstWorks = store.field.works.count
        await store.seedDemoIfNeeded(now: now, calendar: calendar)
        XCTAssertEqual(store.field.works.count, firstWorks)
        XCTAssertTrue(store.field.onboardingComplete)
        XCTAssertTrue(store.field.canLodge)
        XCTAssertEqual(store.field.hangingDonor?.role, .loose)
        XCTAssertNotEqual(store.field.status, .idle)
        XCTAssertGreaterThanOrEqual(store.field.works.count, 6)
        XCTAssertTrue(defaults.bool(forKey: FieldKey.demo))
        XCTAssertNotNil(defaults.data(forKey: FieldKey.snapshot))
    }
    #endif

    @MainActor
    func test_seekFallsBackToLocalShelf() async throws {
        let store = makeStore(client: CatalogClient(hop: FailingHop()))
        await store.load()
        let rows = try await store.seek("irises")
        XCTAssertEqual(rows.first?.title, GettyShelf.bundled.rows[0].title)
        XCTAssertGreaterThanOrEqual(rows.count, 8)
    }

    @MainActor
    func test_emptyQueryDoesNotHitNetwork() async throws {
        let log = RequestLog()
        let store = makeStore(client: CatalogClient(hop: LoggingHop(log: log)))
        let rows = try await store.seek("   ")
        XCTAssertFalse(rows.isEmpty)
        let count = await log.count
        XCTAssertEqual(count, 0)
    }

    @MainActor
    private func makeStore(client: CatalogClient = CatalogClient(hop: FailingHop())) -> FieldStore {
        FieldStore(
            directory: directory,
            suiteName: suiteName,
            client: client,
            caster: LeadingDonorCast(),
            shelf: .bundled,
            writeDelayNanoseconds: 0,
            seekDebounceNanoseconds: 0
        )
    }
}

actor RequestLog {
    private var urls: [URL?] = []

    @discardableResult
    func append(_ url: URL?) -> Int {
        urls.append(url)
        return urls.count
    }

    var count: Int { urls.count }
}

struct FailingHop: CatalogHopping {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        throw URLError(.timedOut)
    }
}

struct LoggingHop: CatalogHopping {
    let log: RequestLog

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        await log.append(request.url)
        throw URLError(.cannotConnectToHost)
    }
}
