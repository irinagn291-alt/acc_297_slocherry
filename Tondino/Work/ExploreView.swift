import SwiftUI

/// Role: Work. Explore sheet. J. Paul Getty Museum search writes a Loose Work. Local Getty shelf when query is empty or search fails.
struct ExploreView: View {
    @Bindable var chrome: FieldChrome
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass
    @FocusState private var searchFocused: Bool

    private var isWide: Bool { FieldPad.isWide(sizeClass) }

    var body: some View {
        NavigationStack {
            Group {
                if chrome.exploreIsEmpty, chrome.seekFault != nil {
                    errorPage
                } else if chrome.exploreIsEmpty {
                    emptyPage
                } else {
                    populated
                }
            }
            .background(FieldInk.background.ignoresSafeArea())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Explore")
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
            .safeAreaInset(edge: .top, spacing: FieldPad.gap) {
                searchField
            }
            .fieldKeyboardDone(focused: $searchFocused)
            .scrollDismissesKeyboard(.immediately)
        }
        .preferredColorScheme(.light)
        .presentationBackground(FieldInk.background)
        .presentationDragIndicator(.visible)
        .task {
            if chrome.seekHits.isEmpty {
                chrome.scheduleSeek()
            }
        }
    }

    private var searchField: some View {
        VStack(alignment: .leading, spacing: FieldPad.inner) {
            Text("J. Paul Getty Museum")
                .font(FieldFace.font(.micro, size: typeSize))
                .foregroundStyle(FieldInk.ink)
                .padding(.horizontal, FieldPad.outer)
            HStack(spacing: FieldPad.gap) {
                TextField("Search a work", text: $chrome.query)
                    .font(FieldFace.font(.body, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .onChange(of: chrome.query) { _, _ in
                        chrome.scheduleSeek()
                    }
                    .onSubmit {
                        searchFocused = false
                    }
                if chrome.isSeeking {
                    ProgressView()
                        .tint(FieldInk.ink)
                        .frame(width: FieldPad.hit, height: FieldPad.hit)
                }
            }
            .padding(FieldPad.card)
            .frame(minHeight: FieldPad.hit)
            .fieldPlate()
            .padding(.horizontal, FieldPad.outer)
            if let note = chrome.crateNote {
                Text(note)
                    .font(FieldFace.font(.micro, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .padding(.horizontal, FieldPad.outer)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let fault = chrome.seekFault, !chrome.seekHits.isEmpty {
                Text(fault)
                    .font(FieldFace.font(.micro, size: typeSize))
                    .foregroundStyle(FieldInk.ink)
                    .padding(FieldPad.inner)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fieldPlate()
                    .padding(.horizontal, FieldPad.outer)
            }
        }
        .padding(.bottom, FieldPad.gap)
        .background(FieldInk.background)
    }

    private var populated: some View {
        Group {
            if isWide {
                padCatalog
            } else {
                listCatalog
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded { searchFocused = false }
        )
    }

    private var padCatalog: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: FieldPad.card),
                    GridItem(.flexible(), spacing: FieldPad.card),
                    GridItem(.flexible(), spacing: FieldPad.card),
                ],
                alignment: .leading,
                spacing: FieldPad.card
            ) {
                ForEach(chrome.seekHits) { row in
                    Button {
                        searchFocused = false
                        Task { await chrome.stowLoose(row) }
                    } label: {
                        VStack(alignment: .leading, spacing: FieldPad.gap) {
                            WorkThumb(url: row.thumbURL, placeholder: FieldArt.groundPanel)
                                .frame(maxWidth: .infinity)
                                .frame(height: FieldPad.step(22))
                                .clipShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
                                .clipped()
                            Text(row.title)
                                .font(FieldFace.font(.body, size: typeSize))
                                .foregroundStyle(FieldInk.ink)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            Text(row.maker)
                                .font(FieldFace.font(.caption, size: typeSize))
                                .foregroundStyle(FieldInk.ink)
                                .lineLimit(1)
                            saveMark(for: row)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(FieldPad.card)
                        .frame(maxWidth: .infinity, minHeight: FieldPad.hit, alignment: .leading)
                        .contentShape(RoundedRectangle(cornerRadius: FieldCurve.card, style: .continuous))
                        .fieldPlate()
                    }
                    .buttonStyle(StowRowStyle())
                    .disabled(chrome.stockingAccession != nil)
                    .accessibilityLabel("\(row.title), \(row.maker)")
                    .accessibilityHint("Saves this work as Loose.")
                }
            }
            .padding(.horizontal, FieldPad.outer)
            .padding(.bottom, FieldPad.outer)
        }
        .scrollIndicators(.hidden)
        .scrollContentBackground(.hidden)
    }

    private var listCatalog: some View {
        List {
            Section {
                ForEach(chrome.seekHits) { row in
                    Button {
                        searchFocused = false
                        Task { await chrome.stowLoose(row) }
                    } label: {
                        HStack(alignment: .center, spacing: FieldPad.gap) {
                            WorkThumb(url: row.thumbURL, placeholder: FieldArt.groundPanel)
                                .frame(width: FieldPad.step(7), height: FieldPad.step(7))
                                .clipShape(RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous))
                                .clipped()
                            VStack(alignment: .leading, spacing: FieldPad.inner) {
                                Text(row.title)
                                    .font(FieldFace.font(.body, size: typeSize))
                                    .foregroundStyle(FieldInk.ink)
                                    .lineLimit(2)
                                Text(row.maker)
                                    .font(FieldFace.font(.caption, size: typeSize))
                                    .foregroundStyle(FieldInk.ink)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: FieldPad.gap)
                            saveMark(for: row)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(StowRowStyle())
                    .disabled(chrome.stockingAccession != nil)
                    .listRowBackground(FieldInk.surface)
                    .listRowSeparatorTint(FieldInk.muted.opacity(0.35))
                    .listRowInsets(
                        EdgeInsets(
                            top: FieldPad.gap,
                            leading: FieldPad.outer,
                            bottom: FieldPad.gap,
                            trailing: FieldPad.outer
                        )
                    )
                    .accessibilityLabel("\(row.title), \(row.maker)")
                    .accessibilityHint("Saves this work as Loose.")
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, FieldPad.outer)
    }

    @ViewBuilder
    private func saveMark(for row: CatalogRow) -> some View {
        if chrome.stockingAccession == row.accession {
            ProgressView()
                .tint(FieldInk.surface)
                .frame(width: FieldPad.hit, height: FieldPad.hit)
                .background(
                    FieldInk.accent,
                    in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                )
        } else {
            Text("Save")
                .font(FieldFace.font(.caption, size: typeSize))
                .foregroundStyle(FieldInk.surface)
                .padding(.horizontal, FieldPad.inner)
                .frame(minWidth: FieldPad.hit, minHeight: FieldPad.hit)
                .background(
                    FieldInk.accent,
                    in: RoundedRectangle(cornerRadius: FieldCurve.chip, style: .continuous)
                )
        }
    }

    private var emptyPage: some View {
        GapPage(
            art: FieldArt.emptyList,
            headline: "Shelf is quiet.",
            line: "Search the Getty, or save from the local shelf.",
            actionTitle: "Show shelf"
        ) {
            chrome.query = ""
            chrome.scheduleSeek()
        }
    }

    private var errorPage: some View {
        GapPage(
            art: FieldArt.emptyList,
            headline: "Search failed.",
            line: chrome.seekFault ?? "Try again. Local shelf is hanging.",
            actionTitle: "Retry"
        ) {
            chrome.scheduleSeek()
        }
    }
}
