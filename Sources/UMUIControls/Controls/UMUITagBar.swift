//
//  UMUITagBar.swift
//  UMUIControls
//
//  A horizontal scrollable bar of selectable tag chips.
//

import SwiftUI

/// Sizing modes for UMUITagBar.
@available(macOS 11.0, *)
public enum UMUITagBarSize: Sendable, Equatable {
    case normal
    case small
}

/// A horizontal scrolling bar of tag chips that can be toggled on/off.
///
/// Usage:
/// ```swift
/// UMUITagBar(tags: allTags, selectedTags: $selectedTags, size: .normal)
/// ```
@available(macOS 11.0, *)
public struct UMUITagBar: View {
    /// The tag labels list.
    public let tags: [String]
    
    /// Binding to the active Set of selections.
    @Binding public var selectedTags: Set<String>
    
    /// The sizing mode of the tag bar.
    public let size: UMUITagBarSize
    
    /// Creates a tag bar.
    /// - Parameters:
    ///   - tags: Array of text tags.
    ///   - selectedTags: Binding to the Set of active tags.
    ///   - size: Sizing mode (default is `.normal`).
    public init(
        tags: [String],
        selectedTags: Binding<Set<String>>,
        size: UMUITagBarSize = .small
    ) {
        self.tags = tags
        self._selectedTags = selectedTags
        self.size = size
    }
    
    private var tagFont: Font {
        return size == .normal ? .body : .caption
    }
    
    private var horizontalPadding: CGFloat {
        return size == .normal ? 12 : 8
    }
    
    private var verticalPadding: CGFloat {
        return size == .normal ? 4 : 2
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: size == .normal ? 8 : 6) {
                ForEach(tags, id: \.self) { tag in
                    Button {
                        if selectedTags.contains(tag) {
                            selectedTags.remove(tag)
                        } else {
                            selectedTags.insert(tag)
                        }
                    } label: {
                        Text(tag)
                            .font(tagFont)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
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
