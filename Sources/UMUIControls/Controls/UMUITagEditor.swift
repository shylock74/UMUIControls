//
//  UMUITagEditor.swift
//  UMUIControls
//
//  An inline tag editor with existing tags display, add/remove, and suggestion cloud.
//

import SwiftUI

/// An inline tag editor with tag chips, removal buttons, and a popover for adding new tags.
///
/// Usage:
/// ```swift
/// UMUITagEditor(tags: $family.tags, availableTags: viewModel.allTags)
/// ```
public struct UMUITagEditor: View {
    @Binding public var tags: [String]
    public let availableTags: [String]
    
    @State private var showPopover = false
    @State private var newTagText = ""
    
    public init(tags: Binding<[String]>, availableTags: [String] = []) {
        self._tags = tags
        self.availableTags = availableTags
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Add Tag Button
            Button {
                showPopover.toggle()
            } label: {
                Label("Add Tag", systemImage: "plus.circle")
                    .foregroundStyle(Color.secondary)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
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
                                .font(.caption2)
                            Button {
                                withAnimation { tags.removeAll { $0 == tag } }
                            } label: {
                                Label("Remove", systemImage: "xmark")
                                    .font(.caption2)
                            }
                            .buttonStyle(.plain)
                            .labelStyle(.iconOnly)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
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
