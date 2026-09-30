import SwiftUI

/// Role: Work. Remote linen for a panel. Spinner waits 150 ms. Fallback is the ground cutout.
struct WorkThumb: View {
    let url: URL?
    var placeholder: String = FieldArt.groundPanel
    @State private var showSpin = false

    var body: some View {
        FieldInk.surface
            .overlay { linen }
            .clipped()
    }

    @ViewBuilder
    private var linen: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                case .failure:
                    fallback
                case .empty:
                    FieldInk.surface
                        .overlay {
                            if showSpin {
                                ProgressView()
                                    .tint(FieldInk.ink)
                            }
                        }
                        .task(id: url) {
                            showSpin = false
                            try? await Task.sleep(for: .milliseconds(150))
                            if !Task.isCancelled {
                                showSpin = true
                            }
                        }
                @unknown default:
                    fallback
                }
            }
        } else {
            fallback
        }
    }

    private var fallback: some View {
        Image(placeholder)
            .resizable()
            .scaledToFit()
            .padding(FieldPad.card)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityHidden(true)
    }
}
