import SwiftUI

/// Role: Work. Saved sheet of filed excerpts and missed guesses. Collecting without a test is the crate clone.
struct SavedView: View {
    @Bindable var chrome: FieldChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var opened: OpenedWork?

    var body: some View {
        NavigationStack {
            Group {
                if chrome.savedIsEmpty {
                    emptyPage
                } else if let fault = chrome.fieldFault, chrome.field.lodgedWorks.isEmpty, chrome.field.reviewableChips.isEmpty {
                    GapPage(
                        art: FieldArt.emptyList,
                        headline: "Saved could not load.",
                        line: fault,
                        actionTitle: "Close"
                    ) {
                        dismiss()
                    }
                } else {
                    populated
                }
            }
            .background(FieldInk.background.ignoresSafeArea())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(FieldInk.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(FieldFace.font(.headline, size: typeSize))
                            .foregroundStyle(FieldInk.ink)
                            .fieldHit()
                    }
                    .buttonStyle(RoundelGlyphStyle())
                    .accessibilityLabel("Close")
                }
            }
            .navigationDestination(item: $opened) { item in
                openedPage(item)
            }
        }
        .preferredColorScheme(.light)
        .presentationBackground(FieldInk.background)
        .presentationDragIndicator(.visible)
    }

    private var emptyPage: some View {
        GapPage(
            art: FieldArt.emptyList,
            headline: "Nothing filed yet.",
            line: "Lodge a matching panel. Missed guesses wait here too.",
            actionTitle: "Lodge"
        ) {
            dismiss()
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: FieldPad.step(2)) {
            ScrollView {
                VStack(alignment: .leading, spacing: FieldPad.step(2)) {
                    tally
                    if let fault = chrome.fieldFault {
                        Text(fault)
                            .font(FieldFace.font(.caption, size: typeSize))
                            .foregroundStyle(FieldInk.ink)
                            .padding(FieldPad.card)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fieldPlate()
                    }
                    if !chrome.field.lodgedWorks.isEmpty {
                        sectionTitle("Filed")
                        workGrid(items: filedItems)
                    }
                    if !missedItems.isEmpty {
                        sectionTitle("Missed")
                        workGrid(items: missedItems)
                    }
                }
                .padding(.horizontal, FieldPad.outer)
                .padding(.top, FieldPad.gap)
                .padding(.bottom, FieldPad.gap)
            }
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            if FieldPad.isWide(sizeClass) {
                fieldBrief
                    .padding(.horizontal, FieldPad.outer)
                    .padding(.bottom, FieldPad.outer)
            }
        }
    }

    private var fieldBrief: some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            Text("Next tondo")
                .font(FieldFace.font(.headline, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(1)
            Text(
                FieldCopy.savedBrief(
                    filed: chrome.field.lodgeMarks.count,
                    missed: chrome.field.chipMarks.count,
                    status: chrome.field.status,
                    canCut: chrome.field.canCut
                )
            )
            .font(FieldFace.font(.body, size: typeSize))
            .foregroundStyle(FieldInk.ink)
            .lineLimit(4)
            Text(FieldCopy.nextTap(status: chrome.field.status, canCut: chrome.field.canCut))
                .font(FieldFace.font(.caption, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(2)
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .fieldPlate()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            FieldCopy.savedBrief(
                filed: chrome.field.lodgeMarks.count,
                missed: chrome.field.chipMarks.count,
                status: chrome.field.status,
                canCut: chrome.field.canCut
            )
        )
    }

    private var tally: some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            Text("Your tondos")
                .font(FieldFace.font(.headline, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(1)
            Text(tallyLine)
                .font(FieldFace.font(.title, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .monospacedDigit()
                .fieldTick(reduceMotion)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            Text("Tap a work to open it.")
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(2)
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fieldPlate()
        .animation(FieldMotion.swap(reduceMotion), value: chrome.field.lodgeMarks.count)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tallyLine) Tap a work to open it.")
    }

    private var tallyLine: String {
        "\(FieldFigures.whole(chrome.field.lodgeMarks.count)) excerpts filed. \(FieldFigures.whole(chrome.field.chipMarks.count)) missed."
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(FieldFace.font(.caption, size: typeSize))
            .foregroundStyle(FieldInk.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }

    private func workGrid(items: [OpenedWork]) -> some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: FieldPad.gap) {
            ForEach(items) { item in
                Button {
                    opened = item
                } label: {
                    workRow(item)
                }
                .buttonStyle(StowRowStyle())
                .accessibilityLabel("\(item.work.title), \(item.work.maker), \(item.status)")
                .accessibilityHint("Opens this work.")
            }
        }
    }

    private var columns: [GridItem] {
        if FieldPad.isWide(sizeClass) {
            return [
                GridItem(.flexible(), spacing: FieldPad.gap),
                GridItem(.flexible(), spacing: FieldPad.gap),
            ]
        }
        return [GridItem(.flexible(), spacing: FieldPad.gap)]
    }

    private var thumbSide: CGFloat {
        FieldPad.isWide(sizeClass) ? FieldPad.step(12) : FieldPad.step(7)
    }

    private func workRow(_ item: OpenedWork) -> some View {
        HStack(alignment: .center, spacing: FieldPad.gap) {
            WorkThumb(url: item.work.thumbURL, placeholder: FieldArt.groundPanel)
                .frame(width: thumbSide, height: thumbSide)
                .clipShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
                .clipped()
            VStack(alignment: .leading, spacing: FieldPad.inner) {
                Text(item.work.title)
                    .font(FieldFace.font(.body, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(item.work.maker)
                    .font(FieldFace.font(.caption, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .lineLimit(1)
                HStack(alignment: .firstTextBaseline, spacing: FieldPad.gap) {
                    Text(item.status)
                        .font(FieldFace.font(.caption, size: typeSize))
                        .foregroundStyle(FieldInk.surface)
                        .padding(.horizontal, FieldPad.inner)
                        .frame(minHeight: FieldPad.step(3))
                        .background(
                            FieldInk.ink,
                            in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                        )
                    Spacer(minLength: FieldPad.inner)
                    Text(FieldFigures.daykey(item.daykey))
                        .font(FieldFace.font(.caption, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                        .monospacedDigit()
                        .lineLimit(1)
                        .layoutPriority(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, minHeight: FieldPad.hit, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: FieldCurve.card, style: .continuous))
        .fieldPlate()
    }

    private func openedPage(_ item: OpenedWork) -> some View {
        VStack(alignment: .leading, spacing: FieldPad.step(2)) {
            WorkThumb(url: item.work.thumbURL, placeholder: FieldArt.groundPanel)
                .frame(maxWidth: .infinity)
                .frame(height: FieldPad.step(22))
                .clipShape(RoundedRectangle(cornerRadius: FieldCurve.card, style: .continuous))
                .clipped()
                .accessibilityHidden(true)
            Text(item.work.title)
                .font(FieldFace.font(.display, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(3)
            Text(item.work.maker)
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(2)
            HStack(alignment: .firstTextBaseline, spacing: FieldPad.gap) {
                Text(item.status)
                    .font(FieldFace.font(.caption, size: typeSize))
                    .foregroundStyle(FieldInk.surface)
                    .padding(.horizontal, FieldPad.inner)
                    .frame(minHeight: FieldPad.hit)
                    .background(
                        FieldInk.ink,
                        in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                    )
                Text(FieldFigures.daykey(item.daykey))
                    .font(FieldFace.font(.caption, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            Text(item.status == "Filed" ? "This excerpt was lodged." : "This panel was a missed guess.")
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(3)
            Spacer(minLength: FieldPad.gap)
            if let url = item.href {
                Link("Open this work", destination: url)
                    .buttonStyle(CutPillStyle(tone: .cut, isLoading: false))
                    .fieldHit()
                    .accessibilityHint("Opens the Getty record for this panel.")
            } else {
                Button("Back to Saved") {
                    opened = nil
                }
                .buttonStyle(CutPillStyle(tone: .cut, isLoading: false))
                .fieldHit()
            }
        }
        .padding(FieldPad.outer)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(FieldInk.background)
        .navigationTitle(item.work.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filedItems: [OpenedWork] {
        chrome.field.lodgedWorks.map { work in
            OpenedWork(
                id: work.id,
                work: work,
                status: "Filed",
                daykey: work.daykey,
                href: workURL(work)
            )
        }
    }

    private var missedItems: [OpenedWork] {
        chrome.field.reviewableChips.compactMap { chip in
            guard let work = missedWork(for: chip) else { return nil }
            return OpenedWork(
                id: chip.id,
                work: work,
                status: "Missed",
                daykey: chip.daykey,
                href: workURL(work)
            )
        }
    }

    private func missedWork(for chip: ChipMark) -> Work? {
        let cards = chrome.field.lodgeMarks.map(\.card) + [chrome.field.tondo.card].compactMap { $0 }
        for card in cards {
            if let ground = card.grounds.first(where: { $0.id == chip.groundID }) {
                return chrome.field.work(ground.workID)
            }
        }
        return chrome.field.work(chip.workID)
    }

    private func workURL(_ work: Work) -> URL? {
        guard let href = work.objectHref, let url = URL(string: href) else { return nil }
        return url
    }
}

private struct OpenedWork: Identifiable, Hashable {
    let id: UUID
    let work: Work
    let status: String
    let daykey: Int
    let href: URL?

    static func == (lhs: OpenedWork, rhs: OpenedWork) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
