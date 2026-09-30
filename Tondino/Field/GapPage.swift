import SwiftUI

/// Role: Field. Full-page empty or error. Cutout, one headline, one line, bottom full-width CTA. Never a crumb in a Spacer.
struct GapPage: View {
    let art: String
    let headline: String
    let line: String
    let actionTitle: String
    var isLoading: Bool = false
    let action: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: FieldPad.step(2)) {
            Image(art)
                .fieldCutout(maxWidth: .infinity, maxHeight: FieldPad.step(22))
            Text(headline)
                .font(FieldFace.font(.display, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(3)
            Text(line)
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .lineLimit(4)
            Spacer(minLength: FieldPad.gap)
            Button(actionTitle, action: action)
                .buttonStyle(CutPillStyle(tone: .cut, isLoading: isLoading))
                .fieldHit()
        }
        .padding(.horizontal, FieldPad.outer)
        .padding(.top, FieldPad.card)
        .padding(.bottom, FieldPad.outer)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(FieldInk.background)
    }
}
