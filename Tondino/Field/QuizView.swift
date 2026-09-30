import SwiftUI

/// Role: Field. Locked Quiz field. Hero-rail: one circular Shard filling remaining height, caption under the tile, four Grounds as a rail, one LodgeMark plus ChipMark stat. Cut and Lodge fuse here.
struct QuizView: View {
    @Bindable var chrome: FieldChrome
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isWide: Bool { FieldPad.isWide(sizeClass) }

    var body: some View {
        Group {
            if chrome.quizIsEmpty {
                idlePage
            } else {
                populated
            }
        }
        .background(FieldInk.background.ignoresSafeArea())
        .sensoryFeedback(.impact(weight: .medium), trigger: chrome.commitPulse)
        .animation(FieldMotion.swap(reduceMotion), value: chrome.field.status)
        .animation(FieldMotion.swap(reduceMotion), value: chrome.showSuccess)
        .fieldPane(item: $chrome.cover) { cover in
            switch cover {
            case .explore:
                ExploreView(chrome: chrome)
                    .fieldSheetEntry(reduceMotion)
            case .saved:
                SavedView(chrome: chrome)
                    .fieldSheetEntry(reduceMotion)
            case .settings:
                SettingsView(chrome: chrome)
                    .fieldSheetEntry(reduceMotion)
            case .twist:
                CutThenLodgeView(chrome: chrome)
                    .fieldSheetEntry(reduceMotion)
            }
        }
    }

    private var idlePage: some View {
        VStack(alignment: .leading, spacing: 0) {
            topChrome
            GapPage(
                art: FieldArt.emptyHome,
                headline: chrome.recoveredNotice ? "Field could not be read." : FieldCopy.gapHeadline,
                line: chrome.recoveredNotice
                    ? "Start a fresh field. Save four works, then cut."
                    : FieldCopy.gapLine,
                actionTitle: "Explore"
            ) {
                chrome.present(.explore)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: 0) {
            topChrome
            if typeSize.isAccessibilitySize {
                ScrollView {
                    fieldStage
                        .padding(.bottom, FieldPad.outer)
                }
                .scrollIndicators(.hidden)
            } else {
                fieldStage
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var fieldStage: some View {
        Group {
            if isWide {
                splitStage
            } else {
                compactStage
            }
        }
        .padding(.top, FieldPad.inner)
        .padding(.bottom, FieldPad.inner)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var compactStage: some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            hero
            copyBlock
            faultRules
            if !grounds.isEmpty {
                groundsRail
            }
            marksPlate
            cutControl
        }
    }

    private var splitStage: some View {
        HStack(alignment: .top, spacing: FieldPad.step(3)) {
            hero
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(alignment: .leading, spacing: FieldPad.step(2)) {
                copyBlock
                faultRules
                if !grounds.isEmpty {
                    groundsGrid
                }
                marksPlate
                cutControl
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private var copyBlock: some View {
        lodgeCaption
        nextTapLine
    }

    @ViewBuilder
    private var faultRules: some View {
        if let fault = chrome.fieldFault {
            faultRule(fault)
        }
        if chrome.recoveredNotice {
            faultRule("Field could not be read.")
        }
    }

    @ViewBuilder
    private var cutControl: some View {
        if chrome.field.canCut {
            Button("Cut") {
                Task { await chrome.cutTondo() }
            }
            .buttonStyle(CutPillStyle(tone: .cut, isLoading: chrome.cutBusy))
            .disabled(chrome.isCutting)
            .padding(.horizontal, isWide ? 0 : FieldPad.outer)
            .accessibilityHint("Punches a circular excerpt from a work that is not lodged.")
        }
    }

    @ViewBuilder
    private var hero: some View {
        if let card = chrome.field.tondo.card {
            ShardHoop(
                work: chrome.field.work(card.shard.workID),
                shard: card.shard,
                showSuccess: chrome.showSuccess
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isWide ? 0 : FieldPad.outer)
            .padding(.leading, isWide ? FieldPad.outer : 0)
        } else {
            Image(FieldArt.tondoHoop)
                .resizable()
                .scaledToFit()
                .padding(FieldPad.card)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(
                    FieldInk.surface,
                    in: Circle()
                )
                .clipShape(Circle())
                .padding(.horizontal, isWide ? 0 : FieldPad.outer)
                .padding(.leading, isWide ? FieldPad.outer : 0)
                .accessibilityHidden(true)
        }
    }

    private var lodgeCaption: some View {
        VStack(alignment: .leading, spacing: FieldPad.inner) {
            Text(FieldCopy.lodgeLine(status: chrome.field.status, canCut: chrome.field.canCut))
                .font(FieldFace.font(.display, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(FieldStatusInk.stamp(chrome.field.status))
                .font(FieldFace.font(isWide ? .body : .caption, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, isWide ? 0 : FieldPad.outer)
        .padding(.trailing, isWide ? FieldPad.outer : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(FieldCopy.lodgeLine(status: chrome.field.status, canCut: chrome.field.canCut)), \(FieldStatusInk.stamp(chrome.field.status))"
        )
    }

    private var nextTapLine: some View {
        Text(FieldCopy.nextTap(status: chrome.field.status, canCut: chrome.field.canCut))
            .font(FieldFace.font(isWide ? .body : .caption, size: typeSize))
            .foregroundStyle(FieldInk.ink)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, isWide ? 0 : FieldPad.outer)
            .padding(.trailing, isWide ? FieldPad.outer : 0)
            .layoutPriority(1)
    }

    private var groundsRail: some View {
        HStack(alignment: .center, spacing: FieldPad.gap) {
            ForEach(grounds) { ground in
                GroundPanel(
                    ground: ground,
                    work: chrome.field.work(ground.workID),
                    isLive: chrome.canTapGrounds,
                    action: {
                        Task { await chrome.tapGround(ground.id) }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(height: FieldPad.step(12))
                .clipped()
            }
        }
        .padding(.horizontal, FieldPad.outer)
        .frame(minHeight: FieldPad.hit)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Four full grounds")
    }

    private var groundsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: FieldPad.gap),
                GridItem(.flexible(), spacing: FieldPad.gap),
            ],
            alignment: .leading,
            spacing: FieldPad.gap
        ) {
            ForEach(grounds) { ground in
                GroundPanel(
                    ground: ground,
                    work: chrome.field.work(ground.workID),
                    isLive: chrome.canTapGrounds,
                    action: {
                        Task { await chrome.tapGround(ground.id) }
                    }
                )
                .frame(maxWidth: .infinity)
                .frame(minHeight: FieldPad.step(18))
                .aspectRatio(1, contentMode: .fit)
                .clipped()
            }
        }
        .padding(.trailing, FieldPad.outer)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Four full grounds")
    }

    private var grounds: [Ground] {
        chrome.field.tondo.card?.grounds ?? []
    }

    private var marksPlate: some View {
        HStack(alignment: .firstTextBaseline, spacing: FieldPad.step(2)) {
            VStack(alignment: .leading, spacing: FieldPad.inner) {
                Text("Filed")
                    .font(FieldFace.font(.micro, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .lineLimit(1)
                Text(FieldFigures.whole(chrome.field.lodgeMarks.count))
                    .font(FieldFace.font(.title, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .monospacedDigit()
                    .fieldTick(reduceMotion)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: FieldPad.inner) {
                Text("Missed")
                    .font(FieldFace.font(.micro, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .lineLimit(1)
                Text(FieldFigures.whole(chrome.field.chipMarks.count))
                    .font(FieldFace.font(.headline, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .monospacedDigit()
                    .fieldTick(reduceMotion)
                    .lineLimit(1)
                    .layoutPriority(1)
                Text(FieldFigures.daykey(chrome.dayStamp))
                    .font(FieldFace.font(.micro, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .monospacedDigit()
                    .lineLimit(1)
            }
            .frame(width: FieldPad.step(14), alignment: .leading)
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, minHeight: FieldPad.step(isWide ? 12 : 10), alignment: .leading)
        .fieldPlate()
        .padding(.horizontal, isWide ? 0 : FieldPad.outer)
        .padding(.trailing, isWide ? FieldPad.outer : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(FieldFigures.whole(chrome.field.lodgeMarks.count)) filed. \(FieldFigures.whole(chrome.field.chipMarks.count)) missed."
        )
    }

    private var topChrome: some View {
        HStack(alignment: .center, spacing: FieldPad.gap) {
            statusButton
            Spacer(minLength: FieldPad.gap)
            undoButton
            sheetButton("Explore", symbol: "magnifyingglass") {
                chrome.present(.explore)
            }
            sheetButton("Saved", symbol: "bookmark") {
                chrome.present(.saved)
            }
            sheetButton("Settings", symbol: "gearshape") {
                chrome.present(.settings)
            }
        }
        .padding(.horizontal, FieldPad.outer)
        .padding(.top, FieldPad.gap)
        .padding(.bottom, FieldPad.gap)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FieldInk.background)
    }

    private var statusButton: some View {
        Button {
            chrome.present(.twist)
        } label: {
            HStack(spacing: FieldPad.inner) {
                Image(FieldArt.controlFace)
                    .resizable()
                    .scaledToFit()
                    .frame(width: FieldPad.step(3), height: FieldPad.step(3))
                    .accessibilityHidden(true)
                Text(FieldStatusInk.stamp(chrome.field.status))
                    .font(FieldFace.font(.caption, size: typeSize))
                    .foregroundStyle(FieldInk.surface)
                    .lineLimit(1)
            }
            .padding(.horizontal, FieldPad.inner)
            .frame(minHeight: FieldPad.hit)
            .background(
                chrome.field.canLodge ? FieldInk.accent : FieldInk.ink,
                in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
            )
            .contentShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
        }
        .buttonStyle(RoundelGlyphStyle())
        .accessibilityLabel("Cut then lodge. \(FieldStatusInk.stamp(chrome.field.status)).")
        .accessibilityHint(FieldCopy.nextTap(status: chrome.field.status, canCut: chrome.field.canCut))
    }

    private var undoButton: some View {
        Button {
            Task { await chrome.liftLastMark() }
        } label: {
            Image(systemName: "arrow.uturn.backward")
                .font(FieldFace.font(.headline, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .frame(minWidth: FieldPad.hit, minHeight: FieldPad.hit)
                .background(
                    FieldInk.surface,
                    in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                )
                .contentShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
        }
        .buttonStyle(RoundelGlyphStyle())
        .disabled(!chrome.peelEnabled)
        .accessibilityLabel("Undo")
        .accessibilityHint("Peels the newest LodgeMark or ChipMark.")
    }

    private func sheetButton(_ title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(FieldFace.font(.headline, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .frame(minWidth: FieldPad.hit, minHeight: FieldPad.hit)
                .background(
                    FieldInk.surface,
                    in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                )
                .contentShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
        }
        .buttonStyle(RoundelGlyphStyle())
        .accessibilityLabel(title)
    }

    private func faultRule(_ text: String) -> some View {
        Text(text)
            .font(FieldFace.font(.caption, size: typeSize))
            .foregroundStyle(FieldInk.ink)
            .padding(FieldPad.inner)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fieldPlate(FieldCurve.chip)
            .padding(.horizontal, FieldPad.outer)
    }
}
