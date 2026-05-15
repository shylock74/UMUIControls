//
//  UMUITagBar.swift
//  UMUIControls
//
//  A horizontal scrollable bar of selectable tag chips.
//

import SwiftUI

/// A horizontal scrolling bar of tag chips that can be toggled on/off.
///
/// Usage:
/// ```swift
/// UMUITagBar(tags: allTags, selectedTags: $selectedTags)
/// ```
public struct UMUITagBar: View {
    public let tags: [String]
    @Binding public var selectedTags: Set<String>
    
    public init(tags: [String], selectedTags: Binding<Set<String>>) {
        self.tags = tags
        self._selectedTags = selectedTags
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Button {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    } label: {
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(selectedTags.contains(tag) ? Color.accentColor : Color.gray.opacity(0.3))
                            .foregroundColor(selectedTags.contains(tag) ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
