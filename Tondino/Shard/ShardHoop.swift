import SwiftUI

/// Role: Shard. Circular excerpt mask. The only custom-drawn Quiz hero. Caption lives under it, never on the cloth.
struct RoundelMask: Shape {
    func path(in rect: CGRect) -> Path {
        Path(ellipseIn: rect)
    }
}

/// Role: Shard. Quiz hero. One circular Shard photo-tile filling remaining height. Soft shadow only here.
struct ShardHoop: View {
    let work: Work?
    let shard: Shard?
    var showSuccess: Bool

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                excerpt(side: side)
                if showSuccess {
                    Image(FieldArt.successMark)
                        .resizable()
                        .scaledToFit()
                        .padding(FieldPad.step(8))
                        .accessibilityHidden(true)
                }
            }
            .frame(width: side, height: side)
            .clipShape(RoundelMask())
            .overlay(RoundelMask().stroke(FieldInk.ink.opacity(0.12), lineWidth: 1))
            .fieldHeroLift()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityName)
    }

    @ViewBuilder
    private func excerpt(side: CGFloat) -> some View {
        let hoop = max(shard?.hoop ?? 0.24, 0.12)
        let focusX = shard?.focusX ?? 0.5
        let focusY = shard?.focusY ?? 0.5
        ZStack {
            FieldInk.surface
            if let url = work?.thumbURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: side / hoop, height: side / hoop)
                            .offset(
                                x: (0.5 - focusX) * side / hoop,
                                y: (0.5 - focusY) * side / hoop
                            )
                            .frame(width: side, height: side)
                            .clipped()
                    case .failure:
                        hoopFallback(side: side)
                    case .empty:
                        FieldInk.surface
                    @unknown default:
                        hoopFallback(side: side)
                    }
                }
            } else {
                hoopFallback(side: side)
            }
        }
        .frame(width: side, height: side)
        .clipped()
    }

    private func hoopFallback(side: CGFloat) -> some View {
        Image(FieldArt.circularShard)
            .resizable()
            .scaledToFit()
            .padding(FieldPad.card)
            .frame(width: side, height: side)
            .accessibilityHidden(true)
    }

    private var accessibilityName: String {
        "Circular excerpt"
    }
}
