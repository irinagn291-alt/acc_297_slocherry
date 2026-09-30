import SwiftUI

/// Role: LodgeMark. Twist screen. Cut-then-lodge is the fold. Home already shows the shard and four grounds. This sheet names the job.
struct CutThenLodgeView: View {
    @Bindable var chrome: FieldChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: FieldPad.step(2)) {
                Image(FieldArt.twistHero)
                    .fieldCutout(maxWidth: .infinity, maxHeight: FieldPad.step(20))
                Text("Cut then lodge.")
                    .font(FieldFace.font(.display, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .lineLimit(2)
                Text("Cut punches a circular shard from a loose work and hangs four full grounds. Lodge files the donor. A miss writes a ChipMark and the excerpt stays.")
                    .font(FieldFace.font(.body, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .lineLimit(5)
                tallyPlate
                VStack(alignment: .leading, spacing: FieldPad.gap) {
                    Text(FieldStatusInk.stamp(chrome.field.status))
                        .font(FieldFace.font(.caption, size: typeSize))
                        .foregroundStyle(FieldInk.surface)
                        .padding(.horizontal, FieldPad.inner)
                        .frame(minHeight: FieldPad.hit)
                        .background(
                            chrome.field.canLodge ? FieldInk.accent : FieldInk.ink,
                            in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                        )
                    Text(FieldCopy.nextTap(status: chrome.field.status, canCut: chrome.field.canCut))
                        .font(FieldFace.font(.body, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                        .lineLimit(3)
                }
                .padding(FieldPad.card)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .fieldPlate()
                if chrome.field.canCut {
                    Button("Cut") {
                        dismiss()
                        Task { await chrome.cutTondo() }
                    }
                    .buttonStyle(CutPillStyle(tone: .cut, isLoading: chrome.cutBusy))
                    .disabled(chrome.isCutting)
                    .fieldHit()
                } else {
                    Button("Lodge") {
                        dismiss()
                    }
                    .buttonStyle(CutPillStyle(tone: .cut, isLoading: false))
                    .fieldHit()
                    .accessibilityHint("Returns to the four grounds on Quiz.")
                }
            }
            .padding(FieldPad.outer)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(FieldInk.background)
            .navigationTitle("Cut then lodge")
            .navigationBarTitleDisplayMode(.inline)
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
        }
        .preferredColorScheme(.light)
        .presentationBackground(FieldInk.background)
        .presentationDragIndicator(.visible)
    }

    private var tallyPlate: some View {
        ZStack(alignment: .topLeading) {
            Image(FieldArt.cardBackdrop)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .accessibilityHidden(true)
            HStack(alignment: .firstTextBaseline, spacing: FieldPad.step(2)) {
                VStack(alignment: .leading, spacing: FieldPad.inner) {
                    Text("LodgeMarks")
                        .font(FieldFace.font(.micro, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                    Text(FieldFigures.whole(chrome.field.lodgeMarks.count))
                        .font(FieldFace.font(.title, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                        .monospacedDigit()
                        .fieldTick(reduceMotion)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: FieldPad.inner) {
                    Text("ChipMarks")
                        .font(FieldFace.font(.micro, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                    Text(FieldFigures.whole(chrome.field.chipMarks.count))
                        .font(FieldFace.font(.headline, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                        .monospacedDigit()
                        .fieldTick(reduceMotion)
                }
                .frame(width: FieldPad.step(12), alignment: .leading)
            }
            .padding(FieldPad.card)
        }
        .frame(maxWidth: .infinity, minHeight: FieldPad.step(11), alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: FieldCurve.card, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(FieldFigures.whole(chrome.field.lodgeMarks.count)) LodgeMarks. \(FieldFigures.whole(chrome.field.chipMarks.count)) ChipMarks."
        )
    }
}
