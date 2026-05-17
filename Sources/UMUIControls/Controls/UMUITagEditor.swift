//
//  UMUITagEditor.swift
//  UMUIControls
//
//  An inline tag editor with existing tags display, add/remove, and suggestion cloud.
//

import SwiftUI

/// Sizing modes for UMUITagEditor.
public enum UMUITagEditorSize: Sendable, Equatable {
    case normal
    case small
}

/// An inline tag editor with tag chips, removal buttons, and a popover for adding new tags.
///
/// Usage:
/// ```swift
/// UMUITagEditor(tags: $family.tags, availableTags: viewModel.allTags, size: .normal)
/// ```
public struct UMUITagEditor: View {
    @Binding public var tags: [String]
    public let availableTags: [String]
    
    /// The sizing mode of the tag editor.
    public let size: UMUITagEditorSize
    
    @State private var showPopover = false
    @State private var newTagText = ""
    
    /// Creates a tag editor.
    /// - Parameters:
    ///   - tags: Binding to the tags array.
    ///   - availableTags: Predefined lists for popover selections.
    ///   - size: Sizing mode (default is `.normal`).
    public init(
        tags: Binding<[String]>,
        availableTags: [String] = [],
        size: UMUITagEditorSize = .small
    ) {
        self._tags = tags
        self.availableTags = availableTags
        self.size = size
    }
    
    private var tagFont: Font {
        return size == .normal ? .body : .caption2
    }
    
    private var buttonFont: Font {
        return size == .normal ? .body : .caption
    }
    
    private var horizontalPadding: CGFloat {
        return size == .normal ? 10 : 8
    }
    
    private var verticalPadding: CGFloat {
        return size == .normal ? 6 : 4
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Add Tag Button
            Button {
                showPopover.toggle()
            } label: {
                Label("Add Tag", systemImage: "plus.circle")
                    .font(buttonFont)
                    .foregroundStyle(Color.secondary)
            }
            .buttonStyle(.bordered)
            .controlSize(size == .normal ? .regular : .small)
            .popover(isPresented: $showPopover) {
                popoverContent
                    .padding()
                    .frame(width: 300)
            }
            
            // Existing Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(tags, id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                                .font(tagFont)
                            Button {
                                withAnimation { tags.removeAll { $0 == tag } }
                            } label: {
                                Label("Remove", systemImage: "xmark")
                                    .font(tagFont)
                            }
                            .buttonStyle(.plain)
                            .labelStyle(.iconOnly)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, verticalPadding)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var popoverContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Popular Tags")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                ForEach(availableTags.prefix(12), id: \.self) { tag in
                    Button {
                        addTag(tag)
                    } label: {
                        Text(tag)
                            .font(.caption)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(tags.contains(tag) ? Color.accentColor : Color.secondary.opacity(0.1))
                            .foregroundStyle(tags.contains(tag) ? Color.white : Color.primary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(tags.contains(tag))
                }
            }
            
            Divider()
            
            HStack {
                Image(systemName: "tag")
                TextField("New Tag", text: $newTagText)
                    .onSubmit { addTag(newTagText) }
                Button {
                    addTag(newTagText)
                } label: {
                    Label("Add", systemImage: "plus")
                }
                .disabled(newTagText.isEmpty)
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
    
    private func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        withAnimation { tags.append(trimmed) }
        newTagText = ""
    }
}
