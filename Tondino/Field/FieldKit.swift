import SwiftUI
import UIKit

/// Role: Field. Snap motion. Press 0.97 in 160ms ease-out. Sheets 0.96 to 1 plus fade. Reduce Motion is opacity only.
enum FieldMotion {
    static let snap = Animation.easeOut(duration: 0.16)
    static let sheet = Animation.easeOut(duration: 0.18)

    static func press(_ reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.16) : snap
    }

    static func swap(_ reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.16) : snap
    }

    static func pane(_ reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeOut(duration: 0.18) : sheet
    }
}

enum FieldArt {
    static let splash = "tnd_Splash"
    static let onboarding1 = "tnd_Onboarding1"
    static let onboarding2 = "tnd_Onboarding2"
    static let onboarding3 = "tnd_Onboarding3"
    static let emptyHome = "tnd_EmptyHome"
    static let emptyList = "tnd_EmptyList"
    static let cardBackdrop = "tnd_CardBackdrop"
    static let controlFace = "tnd_ControlFace"
    static let twistHero = "tnd_TwistHero"
    static let successMark = "tnd_SuccessMark"
    static let headerDecor = "tnd_HeaderDecor"
    static let tondoHoop = "tnd_TondoHoop"
    static let circularShard = "tnd_CircularShard"
    static let groundPanel = "tnd_GroundPanel"
}

enum FieldStatusInk {
    static func stamp(_ status: TondoStatus) -> String {
        switch status {
        case .idle: "Waiting"
        case .cut: "Crop ready"
        case .lodged: "Filed"
        case .chip: "Missed"
        }
    }
}

enum FieldCopy {
    static let gapHeadline = "Field waiting."
    static let gapLine = "Save four works, then cut."
    static let writeFailed = "Write failed. Try again."

    static func fault(_ error: Error) -> String {
        guard let fault = error as? TondoFault else {
            return writeFailed
        }
        switch fault {
        case .alreadyCut:
            return "A shard is live. Lodge it first."
        case .lodgeOnIdle:
            return "Cut a tondo first. Lodge is refused."
        case .chipOnIdle:
            return "Cut a tondo first. Chip is refused."
        case .alreadyLodged:
            return "Already lodged. Cut the next tondo."
        case .unknownGround:
            return "That panel is not hanging."
        case .groundIsDecoy:
            return "That panel missed. The excerpt stays."
        case .chipOnDonor:
            return "The donor files as Lodge, not Chip."
        case .groundSpent:
            return "That panel is already chipped."
        case .nothingToLift:
            return "Nothing to Undo."
        case .emptyAccession:
            return "No accession."
        }
    }

    static func seek(_ fault: CatalogFault) -> String {
        switch fault {
        case .cancelled:
            return "Search cancelled."
        case .missing:
            return "Search missed. Local shelf is hanging."
        case .transport:
            return "Search failed. Local shelf is hanging."
        case .malformed:
            return "Search could not be read. Local shelf is hanging."
        }
    }

    static func nextTap(status: TondoStatus, canCut: Bool) -> String {
        switch status {
        case .idle:
            return canCut ? "Cut a tondo from a loose work." : gapLine
        case .cut:
            return "Tap the panel that owns this excerpt."
        case .lodged:
            return "Filed. Cut the next tondo."
        case .chip:
            return "That panel missed. The excerpt stays."
        }
    }

    static func lodgeLine(status: TondoStatus, canCut: Bool) -> String {
        switch status {
        case .idle:
            return canCut ? "Cut a tondo." : gapHeadline
        case .cut, .chip:
            return "Lodge this tondo"
        case .lodged:
            return "Tondo lodged."
        }
    }

    static func savedBrief(filed: Int, missed: Int, status: TondoStatus, canCut: Bool) -> String {
        "\(FieldFigures.whole(filed)) filed. \(FieldFigures.whole(missed)) missed. \(nextTap(status: status, canCut: canCut))"
    }

    static func crate(_ focus: StowFocus) -> String {
        switch focus {
        case .inserted:
            return "Saved as Loose."
        case .focused:
            return "Already on the field."
        }
    }
}

/// Role: Field. LodgeMark counts, ChipMark counts, and daykeys go through NumberFormatter. Never interpolate.
enum FieldFigures {
    static func whole(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func daykey(_ value: Int) -> String {
        var parts = DateComponents()
        parts.year = value / 10_000
        parts.month = (value / 100) % 100
        parts.day = value % 100
        guard let date = Calendar.current.date(from: parts) else {
            return whole(value)
        }
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("yyyyMMMd")
        return formatter.string(from: date)
    }
}

/// Role: Field. Pill kit. Cut is primary. Undo is peel. resetAllData is wipe.
struct CutPillStyle: ButtonStyle {
    enum Tone {
        case cut
        case peel
        case wipe
    }

    var tone: Tone = .cut
    var isLoading: Bool = false
    var fillsWidth: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        CutPillBody(
            configuration: configuration,
            tone: tone,
            isLoading: isLoading,
            fillsWidth: fillsWidth
        )
    }
}

private struct CutPillBody: View {
    let configuration: ButtonStyle.Configuration
    let tone: CutPillStyle.Tone
    let isLoading: Bool
    let fillsWidth: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        HStack(spacing: FieldPad.inner) {
            if isLoading {
                ProgressView()
                    .tint(labelInk)
            }
            configuration.label
        }
        .font(tone == .cut ? FieldFace.verb(size: typeSize) : FieldFace.font(.headline, size: typeSize))
        .foregroundStyle(labelInk)
        .frame(minWidth: FieldPad.hit, maxWidth: fillsWidth ? .infinity : nil)
        .frame(minHeight: FieldPad.hit)
        .padding(.horizontal, FieldPad.card)
        .padding(.vertical, FieldPad.inner)
        .background(fill, in: Capsule())
        .overlay(Capsule().stroke(stroke, lineWidth: strokeWidth))
        .contentShape(Capsule())
        .scaleEffect(pressed && isEnabled && !reduceMotion ? 0.97 : 1)
        .opacity(visualOpacity(pressed: pressed))
        .animation(FieldMotion.press(reduceMotion), value: pressed)
        .animation(FieldMotion.swap(reduceMotion), value: isEnabled)
        .animation(FieldMotion.swap(reduceMotion), value: isLoading)
        .animation(FieldMotion.swap(reduceMotion), value: isFocused)
    }

    private var fill: Color {
        switch tone {
        case .cut: FieldInk.accent
        case .peel: FieldInk.surface
        case .wipe: FieldInk.ink
        }
    }

    private var labelInk: Color {
        switch tone {
        case .cut: FieldInk.surface
        case .peel: FieldInk.ink
        case .wipe: FieldInk.surface
        }
    }

    private var stroke: Color {
        if isFocused { return FieldInk.ink }
        if tone == .peel { return FieldInk.ink.opacity(0.22) }
        return Color.clear
    }

    private var strokeWidth: CGFloat {
        if isFocused { return 2 }
        if tone == .peel { return 1 }
        return 0
    }

    private func visualOpacity(pressed: Bool) -> Double {
        if !isEnabled { return 0.42 }
        if isLoading { return 0.7 }
        if pressed { return 0.88 }
        return 1
    }
}

/// Role: Field. Pressed and disabled chrome for icon-only sheet controls. Never .plain.
struct RoundelGlyphStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        RoundelGlyphBody(configuration: configuration)
    }
}

private struct RoundelGlyphBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                    .stroke(FieldInk.ink, lineWidth: isFocused ? 2 : 0)
            )
            .scaleEffect(pressed && isEnabled && !reduceMotion ? 0.97 : 1)
            .opacity(glyphOpacity(pressed: pressed))
            .animation(FieldMotion.press(reduceMotion), value: pressed)
            .animation(FieldMotion.swap(reduceMotion), value: isEnabled)
            .animation(FieldMotion.swap(reduceMotion), value: isFocused)
    }

    private func glyphOpacity(pressed: Bool) -> Double {
        if !isEnabled { return 0.42 }
        if pressed { return 0.88 }
        return 1
    }
}

/// Role: Field. Pressed row for Explore crate and Form rows.
struct StowRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StowRowBody(configuration: configuration)
    }
}

private struct StowRowBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .scaleEffect(pressed && isEnabled && !reduceMotion ? 0.97 : 1)
            .opacity(!isEnabled ? 0.55 : (pressed ? 0.88 : 1))
            .animation(FieldMotion.press(reduceMotion), value: pressed)
            .animation(FieldMotion.swap(reduceMotion), value: isEnabled)
    }
}

/// Role: Ground. Pressed chrome for a full panel. One target, min 44pt.
struct GroundPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GroundPressBody(configuration: configuration)
    }
}

private struct GroundPressBody: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let pressed = configuration.isPressed
        configuration.label
            .scaleEffect(pressed && isEnabled && !reduceMotion ? 0.97 : 1)
            .opacity(!isEnabled ? 0.7 : (pressed ? 0.88 : 1))
            .animation(FieldMotion.press(reduceMotion), value: pressed)
            .animation(FieldMotion.swap(reduceMotion), value: isEnabled)
    }
}

extension View {
    func fieldHit() -> some View {
        frame(minWidth: FieldPad.hit, minHeight: FieldPad.hit)
            .contentShape(Rectangle())
    }

    func fieldPane<Item: Identifiable, Pane: View>(
        item: Binding<Item?>,
        @ViewBuilder pane: @escaping (Item) -> Pane
    ) -> some View {
        modifier(FieldPaneModifier(item: item, pane: pane))
    }

    func fieldPlate(_ radius: CGFloat = FieldCurve.card) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return background(FieldInk.surface, in: shape)
    }

    @ViewBuilder
    func fieldTick(_ reduceMotion: Bool) -> some View {
        if reduceMotion {
            self
        } else {
            self.contentTransition(.numericText())
        }
    }

    func fieldKeyboardDone(focused: FocusState<Bool>.Binding) -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused.wrappedValue = false }
                    .font(FieldFace.font(.caption))
                    .foregroundStyle(FieldInk.ink)
                    .fieldHit()
                    .accessibilityLabel("Done")
            }
        }
    }

    func fieldSheetEntry(_ reduceMotion: Bool) -> some View {
        modifier(FieldSheetEntry(reduceMotion: reduceMotion))
    }

    func fieldHeroLift() -> some View {
        shadow(color: FieldLift.color, radius: FieldLift.radius, x: 0, y: FieldLift.y)
    }
}

/// Role: Field. Explore, Saved, and Settings fill the device. iPad uses a page cover so the field is not a stub around a card.
private struct FieldPaneModifier<Item: Identifiable, Pane: View>: ViewModifier {
    @Binding var item: Item?
    @Environment(\.horizontalSizeClass) private var sizeClass
    var pane: (Item) -> Pane

    func body(content: Content) -> some View {
        content
            .sheet(item: compactItem, content: compactPane)
            .fullScreenCover(item: regularItem, content: pane)
    }

    private var isRegular: Bool {
        sizeClass == .regular || UIDevice.current.userInterfaceIdiom == .pad
    }

    private var compactItem: Binding<Item?> {
        Binding(
            get: { isRegular ? nil : item },
            set: { if !isRegular { item = $0 } }
        )
    }

    private var regularItem: Binding<Item?> {
        Binding(
            get: { isRegular ? item : nil },
            set: { if isRegular { item = $0 } }
        )
    }

    private func compactPane(_ value: Item) -> some View {
        pane(value)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(FieldInk.background)
    }
}

private struct FieldSheetEntry: ViewModifier {
    var reduceMotion: Bool
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(appeared || reduceMotion ? 1 : 0.96)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(FieldMotion.pane(reduceMotion)) {
                    appeared = true
                }
            }
    }
}

extension Image {
    @MainActor
    func fieldCutout(maxWidth: CGFloat, maxHeight: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .padding(FieldPad.card)
            .frame(maxWidth: maxWidth, maxHeight: maxHeight, alignment: .leading)
            .background(
                FieldInk.surface,
                in: RoundedRectangle(cornerRadius: FieldCurve.card, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}
