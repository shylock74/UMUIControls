//
//  UMUISearchablePicker.swift
//  UMUIControls
//
//  A picker for lists that are too long for a plain menu: the closed control
//  shows the current choice, and clicking it opens a popover with a search
//  field and a scrollable, filterable list.
//

import SwiftUI

/// One selectable row of a `UMUISearchablePicker`.
///
/// `leading` is a short decoration shown before the title — a flag emoji, a
/// symbol character — and `subtitle` a dimmed trailing detail such as a code.
@available(macOS 12.0, *)
public struct UMUISearchablePickerItem: Identifiable, Equatable {
    /// The value written back into the picker's selection binding.
    public let id: String

    /// The main text of the row.
    public let title: String

    /// An optional dimmed detail shown at the trailing edge.
    public let subtitle: String?

    /// An optional short decoration (emoji or glyph) shown before the title.
    public let leading: String?

    /// Pinned rows are listed first, above a separator, and ignore the search filter.
    public let pinned: Bool

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        leading: String? = nil,
        pinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.leading = leading
        self.pinned = pinned
    }

    /// Whether the row matches a search term, across title, subtitle and id.
    func matches(_ term: String) -> Bool {
        guard !term.isEmpty else { return true }
        let needle = term.lowercased()
        if title.lowercased().contains(needle) { return true }
        if let subtitle = subtitle, subtitle.lowercased().contains(needle) { return true }
        return id.lowercased().contains(needle)
    }
}

/// A picker that trades the native menu for a searchable popover list.
///
/// Usage:
/// ```swift
/// UMUISearchablePicker(label: "Language",
///                      items: languageItems,
///                      selection: $language)
/// ```
@available(macOS 12.0, *)
public struct UMUISearchablePicker: View {
    /// Optional leading label, drawn outside the control itself.
    public let label: String?

    /// Every selectable row, pinned ones included.
    public let items: [UMUISearchablePickerItem]

    /// The id of the currently selected row.
    @Binding public var selection: String

    /// Placeholder text of the search field.
    public let searchPrompt: String

    /// Fixed width reserved for the leading label, when there is one.
    public let labelWidth: CGFloat?

    /// Width of the popover.
    public let popoverWidth: CGFloat

    /// Maximum height of the scrollable result list.
    public let listHeight: CGFloat

    @State private var isPresented = false
    @State private var searchTerm = ""
    @State private var isHovered = false
    @FocusState private var searchFocused: Bool

    public init(
        label: String? = nil,
        items: [UMUISearchablePickerItem],
        selection: Binding<String>,
        searchPrompt: String = "Search",
        labelWidth: CGFloat? = nil,
        popoverWidth: CGFloat = 280,
        listHeight: CGFloat = 300
    ) {
        self.label = label
        self.items = items
        self._selection = selection
        self.searchPrompt = searchPrompt
        self.labelWidth = labelWidth
        self.popoverWidth = popoverWidth
        self.listHeight = listHeight
    }

    private var selectedItem: UMUISearchablePickerItem? {
        items.first { $0.id == selection }
    }

    private var pinnedItems: [UMUISearchablePickerItem] {
        items.filter { $0.pinned }
    }

    private var filteredItems: [UMUISearchablePickerItem] {
        items.filter { !$0.pinned && $0.matches(searchTerm) }
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let label = label {
                HStack(spacing: 0) {
                    Text(label + ":")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
                .frame(width: labelWidth)
            }

            closedControl
        }
        .popover(isPresented: $isPresented, arrowEdge: .bottom) {
            popoverContent
        }
    }

    // MARK: - Closed state

    private var closedControl: some View {
        Button {
            searchTerm = ""
            isPresented = true
        } label: {
            HStack(spacing: 6) {
                if let leading = selectedItem?.leading {
                    Text(leading)
                        .font(.system(size: 13))
                }

                Text(selectedItem?.title ?? selection)
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer(minLength: 4)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(isHovered ? 0.18 : 0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.25), lineWidth: 0.5)
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }

    // MARK: - Popover

    private var popoverContent: some View {
        VStack(spacing: 0) {
            searchField

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(pinnedItems) { item in
                        row(for: item)
                    }

                    if !pinnedItems.isEmpty && !filteredItems.isEmpty {
                        Divider()
                            .padding(.vertical, 2)
                    }

                    ForEach(filteredItems) { item in
                        row(for: item)
                    }

                    if filteredItems.isEmpty && !searchTerm.isEmpty {
                        Text("No match")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 12)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: listHeight)
        }
        .frame(width: popoverWidth)
        .onAppear {
            // The popover takes a beat to become key; focusing straight away is dropped.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                searchFocused = true
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            TextField(searchPrompt, text: $searchTerm)
                .textFieldStyle(.plain)
                .font(.caption)
                .focused($searchFocused)

            if !searchTerm.isEmpty {
                Button {
                    searchTerm = ""
                    searchFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
    }

    private func row(for item: UMUISearchablePickerItem) -> some View {
        UMUISearchablePickerRow(item: item,
                                isSelected: item.id == selection) {
            selection = item.id
            isPresented = false
        }
    }
}

// MARK: - Row

/// A single popover row, split out so each one owns its own hover state.
@available(macOS 12.0, *)
private struct UMUISearchablePickerRow: View {
    let item: UMUISearchablePickerItem
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let leading = item.leading {
                    Text(leading)
                        .font(.system(size: 14))
                        .frame(width: 20, alignment: .center)
                }

                Text(item.title)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer(minLength: 4)

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.accentColor)
                    .opacity(isSelected ? 1 : 0)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.accentColor.opacity(isHovered ? 0.20 : 0.0))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .onHover { isHovered = $0 }
    }
}
