import SwiftUI

/// Role: Field. One-shot cover. Three pages. Continue full width at the bottom. Skip writes defaults. Re-runnable from Settings.
struct OnboardingCover: View {
    var onSkip: () -> Void
    var onFinish: () -> Void
    @State private var page = 0
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                if page < 2 {
                    Button("Skip", action: onSkip)
                        .font(FieldFace.font(.caption, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                        .fieldHit()
                        .buttonStyle(RoundelGlyphStyle())
                        .accessibilityLabel("Skip onboarding")
                }
            }
            .padding(.horizontal, FieldPad.outer)

            Group {
                switch page {
                case 0:
                    pageBody(
                        art: FieldArt.onboarding1,
                        headline: "Lodge the tondo.",
                        line: "A circular excerpt sits over four full panels. Tap the panel that owns it."
                    )
                case 1:
                    pageBody(
                        art: FieldArt.onboarding2,
                        headline: "Cut then lodge.",
                        line: "Cut punches a roundel from a work you have not lodged yet, then hangs four grounds."
                    )
                default:
                    pageBody(
                        art: FieldArt.onboarding3,
                        headline: "Keep your crate.",
                        line: "Lodged works rest on Saved. A miss writes a ChipMark and the excerpt stays."
                    )
                }
            }
            .id(page)
            .animation(FieldMotion.swap(reduceMotion), value: page)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            HStack(spacing: FieldPad.gap) {
                ForEach(0 ..< 3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                        .fill(index == page ? FieldInk.accent : FieldInk.surface)
                        .frame(width: index == page ? FieldPad.step(3) : FieldPad.inner, height: FieldPad.inner)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, FieldPad.outer)
            .padding(.bottom, FieldPad.inner)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Page \(FieldFigures.whole(page + 1)) of \(FieldFigures.whole(3))")

            Button("Continue") {
                if page < 2 {
                    page += 1
                } else {
                    onFinish()
                }
            }
            .buttonStyle(CutPillStyle(tone: .cut, isLoading: false))
            .padding(.horizontal, FieldPad.outer)
            .padding(.bottom, FieldPad.outer)
        }
        .background(FieldInk.background.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private func pageBody(art: String, headline: String, line: String) -> some View {
        VStack(alignment: .leading, spacing: FieldPad.step(2)) {
            Image(art)
                .fieldCutout(maxWidth: .infinity, maxHeight: FieldPad.step(36))
            Text(headline)
                .font(FieldFace.font(.display, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(3)
            Text(line)
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(4)
            Spacer(minLength: FieldPad.gap)
        }
        .padding(.horizontal, FieldPad.outer)
        .padding(.top, FieldPad.card)
    }
}
