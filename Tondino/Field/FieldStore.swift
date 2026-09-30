import Foundation
import Observation

/// Role: Field. Observable fold owner. Memory is the source of truth. UserDefaults is the projection. Views call cutTondo, lodgeGround, chipGround, and liftLastMark.
@MainActor
@Observable
final class FieldStore {
    static let seekDebounceNanoseconds: UInt64 = 500_000_000

    private(set) var field: Field
    private(set) var warning: FieldWarning?
    private(set) var lastWriteError: String?

    private let vault: FieldVault
    private let client: CatalogClient
    private let caster: any RoundelCasting
    private let shelf: GettyShelf
    private let writeDelayNanoseconds: UInt64
    private let seekDebounce: UInt64
    private var persistTask: Task<Void, Never>?
    private var seekTask: Task<[CatalogRow], Error>?

    init(
        directory: URL,
        suiteName: String? = nil,
        client: CatalogClient = CatalogClient(),
        caster: any RoundelCasting = RotateRoundelCast(),
        shelf: GettyShelf = .bundled,
        writeDelayNanoseconds: UInt64 = 280_000_000,
        seekDebounceNanoseconds: UInt64 = FieldStore.seekDebounceNanoseconds
    ) {
        self.vault = FieldVault(directory: directory, suiteName: suiteName)
        self.client = client
        self.caster = caster
        self.shelf = shelf
        self.writeDelayNanoseconds = writeDelayNanoseconds
        self.seekDebounce = seekDebounceNanoseconds
        self.field = .empty
        self.warning = nil
        self.lastWriteError = nil
    }

    convenience init() {
        let directory: URL
        do {
            directory = try FieldVault.applicationSupportDirectory()
        } catch {
            directory = FileManager.default.temporaryDirectory.appendingPathComponent("Slocherry", isDirectory: true)
        }
        self.init(directory: directory)
    }

    func load() async {
        let loaded = await vault.load()
        field = loaded.field
        warning = loaded.warning
        lastWriteError = nil
    }

    func cutTondo(now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = field
        try next.cutTondo(now: now, calendar: calendar, caster: caster)
        field = next
        await persistNow()
    }

    func lodgeGround(_ groundID: UUID, now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = field
        _ = try next.lodgeGround(groundID, now: now, calendar: calendar)
        field = next
        await persistNow()
    }

    func chipGround(_ groundID: UUID, now: Date = Date(), calendar: Calendar = .current) async throws {
        var next = field
        try next.chipGround(groundID, now: now, calendar: calendar)
        field = next
        await persistNow()
    }

    func liftLastMark() async throws {
        var next = field
        try next.liftLastMark()
        field = next
        await persistNow()
    }

    @discardableResult
    func stowLoose(_ row: CatalogRow, now: Date = Date(), calendar: Calendar = .current) async throws -> StowFocus {
        var next = field
        let focus = try next.stowLoose(row, now: now, calendar: calendar)
        field = next
        await persistNow()
        return focus
    }

    func seek(_ query: String, page: Int = 1, pageSize: Int = 8) async throws -> [CatalogRow] {
        seekTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return field.fallbackRows(shelf: shelf.rows)
        }
        let client = self.client
        let delay = seekDebounce
        let task = Task { () throws -> [CatalogRow] in
            if delay > 0 {
                try await Task.sleep(nanoseconds: delay)
            }
            try Task.checkCancellation()
            return try await client.search(query: trimmed, page: page, pageSize: pageSize)
        }
        seekTask = task
        do {
            let rows = try await task.value
            if Task.isCancelled { throw CatalogFault.cancelled }
            if rows.isEmpty {
                return field.fallbackRows(shelf: shelf.rows)
            }
            var next = field
            next.remember(rows)
            field = next
            await persistNow()
            return rows
        } catch is CancellationError {
            throw CatalogFault.cancelled
        } catch let fault as CatalogFault where fault == .cancelled {
            throw fault
        } catch {
            return field.fallbackRows(shelf: shelf.rows)
        }
    }

    func setOnboardingComplete(_ flag: Bool) async {
        var next = field
        next.setOnboardingComplete(flag)
        field = next
        schedulePersist()
    }

    func flush() async {
        persistTask?.cancel()
        persistTask = nil
        await persistNow()
    }

    func resetAllData() async {
        persistTask?.cancel()
        persistTask = nil
        seekTask?.cancel()
        seekTask = nil
        field = .empty
        warning = nil
        lastWriteError = nil
        do {
            try await vault.wipe()
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    func seedDemoIfNeeded(now: Date = Date(), calendar: Calendar = .current) async {
        #if targetEnvironment(simulator)
        if await vault.demoPlanted() { return }
        field = FieldSeed.field(now: now, calendar: calendar, caster: caster, shelf: shelf.rows)
        await vault.markDemoPlanted()
        await persistNow()
        #else
        _ = now
        _ = calendar
        #endif
    }

    private func persistNow() async {
        do {
            try await vault.save(field)
            lastWriteError = nil
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    private func schedulePersist() {
        persistTask?.cancel()
        let delay = writeDelayNanoseconds
        persistTask = Task { [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.persistNow()
        }
    }
}
