import Foundation
import Observation
import SwiftUI

/// Role: Field. Presentation fold over FieldStore. Views call cutTondo, lodgeGround, chipGround, and liftLastMark and never keep a second Tondo enum.
@MainActor
@Observable
final class FieldChrome {
    let store: FieldStore
    private(set) var field: Field
    var isBooting: Bool
    var showsOnboarding: Bool
    var cover: FieldCover?
    var recoveredNotice: Bool
    var isCutting: Bool
    var cutBusy: Bool
    var isJudging: Bool
    var isPeeling: Bool
    var peelBusy: Bool
    var isSeeking: Bool
    var query: String
    var seekHits: [CatalogRow]
    var seekFault: String?
    var fieldFault: String?
    var crateNote: String?
    var stockingAccession: String?
    var commitPulse: Int
    var showSuccess: Bool
    var dayStamp: Int
    private var cueConsumed: Bool
    private var pendingJob: FieldJob?
    private var seekTask: Task<Void, Never>?
    private var successTask: Task<Void, Never>?

    init(store: FieldStore, isBooting: Bool = true) {
        self.store = store
        self.field = store.field
        self.isBooting = isBooting
        self.showsOnboarding = false
        self.cover = nil
        self.recoveredNotice = false
        self.isCutting = false
        self.cutBusy = false
        self.isJudging = false
        self.isPeeling = false
        self.peelBusy = false
        self.isSeeking = false
        self.query = ""
        self.seekHits = []
        self.seekFault = nil
        self.fieldFault = nil
        self.crateNote = nil
        self.stockingAccession = nil
        self.commitPulse = 0
        self.showSuccess = false
        self.dayStamp = DayStamp.stamp(Date(), calendar: .current)
        self.cueConsumed = false
    }

    static func live() -> FieldChrome {
        FieldChrome(store: FieldStore())
    }

    func boot() async {
        guard isBooting else { return }
        await store.load()
        await store.seedDemoIfNeeded()
        sync()
        recoveredNotice = store.warning != nil
        showsOnboarding = !field.onboardingComplete
        isBooting = false
        if query.isEmpty {
            seekHits = field.fallbackRows(shelf: GettyShelf.bundled.rows)
        }
        if !showsOnboarding {
            consumeCue()
        }
    }

    func flush() async {
        await store.flush()
        sync()
    }

    func reload() async {
        await store.load()
        sync()
        recoveredNotice = store.warning != nil
        if query.isEmpty {
            seekHits = field.fallbackRows(shelf: GettyShelf.bundled.rows)
        }
    }

    func refreshDay() {
        dayStamp = DayStamp.stamp(Date(), calendar: .current)
    }

    func handle(phase: ScenePhase) async {
        switch phase {
        case .inactive, .background:
            await flush()
        case .active:
            refreshDay()
        @unknown default:
            break
        }
    }

    func finishOnboarding() async {
        await store.setOnboardingComplete(true)
        await store.flush()
        sync()
        showsOnboarding = false
        if let pending = pendingJob {
            pendingJob = nil
            handle(pending)
        } else {
            consumeCue()
        }
    }

    func replayOnboarding() {
        cover = nil
        showsOnboarding = true
        Task {
            await store.setOnboardingComplete(false)
            await store.flush()
            sync()
        }
    }

    func present(_ cover: FieldCover) {
        self.cover = cover
    }

    func handle(_ job: FieldJob) {
        if showsOnboarding {
            pendingJob = job
            return
        }
        switch job {
        case .quiz:
            cover = nil
        case .cut:
            cover = nil
            Task { await cutTondo() }
        case .lodge:
            cover = nil
            Task { await lodgeDonor() }
        case .explore, .saved, .settings, .twist:
            cover = job.cover
        }
    }

    func handle(url: URL) {
        guard let job = FieldJob.parse(url) else { return }
        handle(job)
    }

    func cutTondo() async {
        guard !isCutting, field.canCut else { return }
        isCutting = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { cutBusy = true }
        }
        do {
            try await store.cutTondo()
            showSuccess = false
            sync()
            if store.lastWriteError == nil {
                fieldFault = nil
            }
        } catch {
            fieldFault = FieldCopy.fault(error)
            sync()
        }
        pulse.cancel()
        cutBusy = false
        isCutting = false
        sync()
    }

    func tapGround(_ groundID: UUID) async {
        guard !isJudging, field.canLodge else { return }
        guard let ground = field.tondo.card?.grounds.first(where: { $0.id == groundID }) else { return }
        if ground.isDonor {
            await lodgeGround(groundID)
        } else {
            await chipGround(groundID)
        }
    }

    func lodgeDonor() async {
        guard let id = field.tondo.card?.donorGround?.id else {
            fieldFault = FieldCopy.fault(TondoFault.lodgeOnIdle)
            return
        }
        await lodgeGround(id)
    }

    func lodgeGround(_ groundID: UUID) async {
        guard !isJudging else { return }
        isJudging = true
        do {
            try await store.lodgeGround(groundID)
            sync()
            if field.status == .lodged {
                commitPulse += 1
                flashSuccess()
            }
            if store.lastWriteError == nil {
                fieldFault = nil
            }
        } catch {
            fieldFault = FieldCopy.fault(error)
            sync()
        }
        isJudging = false
        sync()
    }

    func chipGround(_ groundID: UUID) async {
        guard !isJudging else { return }
        isJudging = true
        do {
            try await store.chipGround(groundID)
            showSuccess = false
            sync()
            if store.lastWriteError == nil {
                fieldFault = nil
            }
        } catch {
            fieldFault = FieldCopy.fault(error)
            sync()
        }
        isJudging = false
        sync()
    }

    func liftLastMark() async {
        guard !isPeeling else { return }
        isPeeling = true
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { peelBusy = true }
        }
        do {
            try await store.liftLastMark()
            showSuccess = false
            sync()
            if store.lastWriteError == nil {
                fieldFault = nil
            }
        } catch {
            fieldFault = FieldCopy.fault(error)
            sync()
        }
        pulse.cancel()
        peelBusy = false
        isPeeling = false
        sync()
    }

    func stowLoose(_ row: CatalogRow) async {
        guard stockingAccession == nil else { return }
        stockingAccession = row.accession
        do {
            let focus = try await store.stowLoose(row)
            sync()
            crateNote = FieldCopy.crate(focus)
            fieldFault = nil
        } catch {
            crateNote = FieldCopy.fault(error)
        }
        stockingAccession = nil
        if store.lastWriteError != nil {
            fieldFault = FieldCopy.writeFailed
        }
    }

    func scheduleSeek() {
        seekTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        seekTask = Task { await seek(trimmed) }
    }

    func resetAllData() async {
        seekTask?.cancel()
        successTask?.cancel()
        await store.resetAllData()
        sync()
        cover = nil
        query = ""
        seekHits = field.fallbackRows(shelf: GettyShelf.bundled.rows)
        seekFault = nil
        fieldFault = nil
        crateNote = nil
        recoveredNotice = false
        showSuccess = false
        showsOnboarding = true
        cueConsumed = true
        pendingJob = nil
    }

    var peelEnabled: Bool {
        !field.peelLog.isEmpty && !isPeeling
    }

    var quizIsEmpty: Bool {
        field.works.count < 4
    }

    var savedIsEmpty: Bool {
        field.lodgedWorks.isEmpty && field.reviewableChips.isEmpty
    }

    var exploreIsEmpty: Bool {
        seekHits.isEmpty && !isSeeking
    }

    var settingsIsEmpty: Bool {
        field.works.isEmpty
            && field.lodgeMarks.isEmpty
            && field.chipMarks.isEmpty
    }

    var canTapGrounds: Bool {
        field.canLodge && !isJudging
    }

    private func seek(_ trimmed: String) async {
        if trimmed.isEmpty {
            isSeeking = false
            seekFault = nil
            seekHits = field.fallbackRows(shelf: GettyShelf.bundled.rows)
            return
        }
        let pulse = Task {
            try await Task.sleep(for: .milliseconds(150))
            if !Task.isCancelled { isSeeking = true }
        }
        defer {
            pulse.cancel()
            isSeeking = false
        }
        do {
            let hits = try await store.seek(trimmed)
            if Task.isCancelled { return }
            sync()
            seekHits = hits
            let fallbackIDs = field.fallbackRows(shelf: GettyShelf.bundled.rows).map(\.accession)
            if hits.map(\.accession) == fallbackIDs {
                seekFault = FieldCopy.seek(.missing)
            } else {
                seekFault = nil
            }
        } catch is CancellationError {
            return
        } catch let fault as CatalogFault where fault == .cancelled {
            return
        } catch let fault as CatalogFault {
            if Task.isCancelled { return }
            sync()
            seekHits = field.fallbackRows(shelf: GettyShelf.bundled.rows)
            seekFault = FieldCopy.seek(fault)
        } catch {
            if Task.isCancelled { return }
            sync()
            seekHits = field.fallbackRows(shelf: GettyShelf.bundled.rows)
            seekFault = FieldCopy.seek(.transport)
        }
    }

    private func flashSuccess() {
        successTask?.cancel()
        showSuccess = true
        successTask = Task {
            try? await Task.sleep(for: .milliseconds(1200))
            if !Task.isCancelled {
                showSuccess = false
            }
        }
    }

    private func sync() {
        field = store.field
        if store.lastWriteError != nil {
            fieldFault = FieldCopy.writeFailed
        }
    }

    private func consumeCue() {
        if let hook = FieldLinks.consume(
            arguments: ProcessInfo.processInfo.arguments,
            onboardingComplete: field.onboardingComplete,
            consumed: &cueConsumed
        ) {
            cover = cover(from: hook.sheet)
        }
    }

    private func cover(from sheet: FieldSheet) -> FieldCover? {
        switch sheet {
        case .quiz: nil
        case .explore: .explore
        case .saved: .saved
        case .settings: .settings
        }
    }
}
