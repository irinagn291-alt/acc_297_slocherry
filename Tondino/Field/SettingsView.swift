import SwiftUI

/// Role: Field. Settings Form. Getty credit, Undo, contact URL, re-run onboarding, confirmed resetAllData.
struct SettingsView: View {
    @Bindable var chrome: FieldChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var confirmReset = false

    private var isWide: Bool { FieldPad.isWide(sizeClass) }

    var body: some View {
        NavigationStack {
            Group {
                if isWide {
                    padPage
                } else {
                    phoneForm
                }
            }
            .background(FieldInk.background)
            .tint(FieldInk.accent)
            .navigationTitle("Settings")
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
            .alert("Reset the field?", isPresented: $confirmReset) {
                Button("Keep", role: .cancel) {}
                Button("Reset the field", role: .destructive) {
                    Task { await chrome.resetAllData() }
                }
            } message: {
                Text("This removes works, shards, filed tondos, and missed guesses on this device. It cannot be undone.")
            }
        }
        .preferredColorScheme(.light)
        .presentationBackground(FieldInk.background)
        .presentationDragIndicator(.visible)
    }

    private var padPage: some View {
        ScrollView {
            HStack(alignment: .top, spacing: FieldPad.step(3)) {
                VStack(alignment: .leading, spacing: FieldPad.step(2)) {
                    if chrome.settingsIsEmpty {
                        emptyPlate
                    } else {
                        progressPlate
                    }
                    if let fault = chrome.fieldFault {
                        faultPlate(fault)
                    }
                    collectionPlate
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                VStack(alignment: .leading, spacing: FieldPad.step(2)) {
                    actionPlate
                    resetButton
                    contactLink
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(FieldPad.outer)
        }
        .scrollContentBackground(.hidden)
    }

    private var phoneForm: some View {
        Form {
            if chrome.settingsIsEmpty {
                Section {
                    Text(FieldCopy.gapHeadline)
                        .font(FieldFace.font(.body, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                    Text(FieldCopy.gapLine)
                        .font(FieldFace.font(.caption, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                    Button("Explore") {
                        chrome.present(.explore)
                    }
                    .buttonStyle(CutPillStyle(tone: .cut, isLoading: false))
                    .listRowInsets(rowInsets)
                    .listRowBackground(FieldInk.background)
                    .listRowSeparator(.hidden)
                }
            } else {
                Section {
                    filedRow
                    missedRow
                } header: {
                    Text("Progress")
                        .font(FieldFace.font(.caption, size: typeSize))
                }
            }

            if let fault = chrome.fieldFault {
                Section {
                    Text(fault)
                        .font(FieldFace.font(.body, size: typeSize))
                        .foregroundStyle(FieldInk.ink)
                } header: {
                    Text("Write")
                        .font(FieldFace.font(.caption, size: typeSize))
                }
            }

            Section {
                filledLink(
                    title: "J. Paul Getty Museum",
                    detail: "getty.edu",
                    url: CatalogClient.gettyHomeURL,
                    tone: .peel
                )
                filledLink(
                    title: "Open Content Program",
                    detail: "getty.edu/projects/open-content-program",
                    url: CatalogClient.gettyOpenContentURL,
                    tone: .peel
                )
            } header: {
                Text("Collection")
                    .font(FieldFace.font(.caption, size: typeSize))
            } footer: {
                Text("Public-domain works hang from the J. Paul Getty Museum.")
                    .font(FieldFace.font(.micro, size: typeSize))
            }

            Section {
                undoButton
                rerunButton
            } footer: {
                Text(actionFooter)
                    .font(FieldFace.font(.caption, size: typeSize))
            }

            Section {
                resetButton
                    .listRowInsets(rowInsets)
                    .listRowBackground(FieldInk.background)
                    .listRowSeparator(.hidden)
                contactLink
                    .listRowInsets(rowInsets)
                    .listRowBackground(FieldInk.background)
                    .listRowSeparator(.hidden)
            }
        }
        .scrollContentBackground(.hidden)
        .background(FieldInk.background)
    }

    private var emptyPlate: some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            Text(FieldCopy.gapHeadline)
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
            Text(FieldCopy.gapLine)
                .font(FieldFace.font(.caption, size: typeSize))
                .foregroundStyle(FieldInk.ink)
            Button("Explore") {
                chrome.present(.explore)
            }
            .buttonStyle(CutPillStyle(tone: .cut, isLoading: false))
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fieldPlate()
    }

    private var progressPlate: some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            Text("Progress")
                .font(FieldFace.font(.caption, size: typeSize))
                .foregroundStyle(FieldInk.ink)
            filedRow
            missedRow
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fieldPlate()
    }

    private func faultPlate(_ fault: String) -> some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            Text("Write")
                .font(FieldFace.font(.caption, size: typeSize))
                .foregroundStyle(FieldInk.ink)
            Text(fault)
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fieldPlate()
    }

    private var collectionPlate: some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            Text("Collection")
                .font(FieldFace.font(.caption, size: typeSize))
                .foregroundStyle(FieldInk.ink)
            filledLink(
                title: "J. Paul Getty Museum",
                detail: "getty.edu",
                url: CatalogClient.gettyHomeURL,
                tone: .peel
            )
            filledLink(
                title: "Open Content Program",
                detail: "getty.edu/projects/open-content-program",
                url: CatalogClient.gettyOpenContentURL,
                tone: .peel
            )
            Text("Public-domain works hang from the J. Paul Getty Museum.")
                .font(FieldFace.font(.micro, size: typeSize))
                .foregroundStyle(FieldInk.ink)
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fieldPlate()
    }

    private var actionPlate: some View {
        VStack(alignment: .leading, spacing: FieldPad.gap) {
            undoButton
            rerunButton
            Text(actionFooter)
                .font(FieldFace.font(.caption, size: typeSize))
                .foregroundStyle(FieldInk.ink)
        }
        .padding(FieldPad.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fieldPlate()
    }

    private var filedRow: some View {
        HStack {
            Text("Filed")
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
            Spacer()
            Text(FieldFigures.whole(chrome.field.lodgeMarks.count))
                .font(FieldFace.font(.headline, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .monospacedDigit()
                .layoutPriority(1)
        }
        .frame(minHeight: FieldPad.hit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Filed, \(FieldFigures.whole(chrome.field.lodgeMarks.count))")
    }

    private var missedRow: some View {
        HStack {
            Text("Missed")
                .font(FieldFace.font(.body, size: typeSize))
                .foregroundStyle(FieldInk.ink)
            Spacer()
            Text(FieldFigures.whole(chrome.field.chipMarks.count))
                .font(FieldFace.font(.headline, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .monospacedDigit()
                .layoutPriority(1)
        }
        .frame(minHeight: FieldPad.hit)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Missed, \(FieldFigures.whole(chrome.field.chipMarks.count))")
    }

    private var undoButton: some View {
        Button {
            Task { await chrome.liftLastMark() }
        } label: {
            HStack {
                Text("Undo")
                    .font(FieldFace.font(.body, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                Spacer()
                if chrome.peelBusy {
                    ProgressView()
                        .tint(FieldInk.ink)
                }
            }
            .frame(maxWidth: .infinity, minHeight: FieldPad.hit, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(StowRowStyle())
        .disabled(!chrome.peelEnabled)
    }

    private var rerunButton: some View {
        Button("Re-run onboarding") {
            chrome.replayOnboarding()
        }
        .font(FieldFace.font(.body, size: typeSize))
        .foregroundStyle(FieldInk.ink)
        .frame(maxWidth: .infinity, minHeight: FieldPad.hit, alignment: .leading)
        .contentShape(Rectangle())
        .buttonStyle(StowRowStyle())
        .accessibilityHint("Shows the intro again. Works and marks stay.")
    }

    private var resetButton: some View {
        Button("Reset the field") {
            confirmReset = true
        }
        .buttonStyle(CutPillStyle(tone: .wipe, isLoading: false))
        .accessibilityLabel("Reset the field")
        .accessibilityHint("Removes works and marks on this device.")
    }

    private var contactLink: some View {
        Link(destination: CatalogClient.contactURL) {
            VStack(spacing: FieldPad.inner) {
                Text("Contact")
                    .font(FieldFace.font(.headline, size: typeSize))
                Text("tondino-field.pro/contact-us")
                    .font(FieldFace.font(.caption, size: typeSize))
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(CutPillStyle(tone: .cut, isLoading: false))
        .accessibilityLabel("Contact tondino-field.pro/contact-us")
    }

    private var actionFooter: String {
        "Undo peels the newest filed or missed tondo. Re-run onboarding shows the intro again. Reset removes works and marks on this device."
    }

    private var rowInsets: EdgeInsets {
        EdgeInsets(
            top: FieldPad.gap,
            leading: FieldPad.outer,
            bottom: FieldPad.gap,
            trailing: FieldPad.outer
        )
    }

    private func filledLink(title: String, detail: String, url: URL, tone: CutPillStyle.Tone) -> some View {
        Link(destination: url) {
            VStack(alignment: .leading, spacing: FieldPad.inner) {
                Text(title)
                    .font(FieldFace.font(.headline, size: typeSize))
                    .lineLimit(2)
                Text(detail)
                    .font(FieldFace.font(.caption, size: typeSize))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(CutPillStyle(tone: tone, isLoading: false))
        .listRowInsets(rowInsets)
        .listRowBackground(FieldInk.background)
        .listRowSeparator(.hidden)
        .accessibilityLabel("\(title), \(detail)")
    }
}
