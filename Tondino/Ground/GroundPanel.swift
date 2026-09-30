import SwiftUI

/// Role: Ground. One full panel Button on the grounds rail. Miss cools and strikes. Colour is never the only chip signal.
struct GroundPanel: View {
    let ground: Ground
    let work: Work?
    var isLive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                WorkThumb(url: work?.thumbURL, placeholder: FieldArt.groundPanel)
                if ground.isCooled {
                    FieldInk.ink.opacity(0.38)
                }
                if ground.isStruck {
                    Rectangle()
                        .fill(FieldInk.ink)
                        .frame(height: 3)
                        .rotationEffect(.degrees(-28))
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: FieldPad.hit, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
            .clipped()
            .contentShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
        }
        .buttonStyle(GroundPressStyle())
        .disabled(!isLive || ground.isCooled)
        .accessibilityLabel(label)
        .accessibilityHint("Lodge if this panel owns the excerpt.")
    }

    private var label: String {
        let title = work?.title ?? "Full panel"
        if ground.isStruck || ground.isCooled {
            return "Chipped panel, \(title)"
        }
        return "Full panel, \(title)"
    }
}
