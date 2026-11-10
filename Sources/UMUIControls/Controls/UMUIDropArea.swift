//
//  UMUIDropArea.swift
//  UMUIControls
//
//  A premium, reusable drag-and-drop target view with hover states,
//  dynamic badge counts, and support for primary selection tap actions.
//

import SwiftUI

/// UMUIDropArea is a premium, reusable component for handling file and folder drag-and-drop operations.
///
/// Behavior:
/// - Visually reacts to drag hovering by changing the border and background color.
/// - Displays an optional count badge for tracked items.
/// - Supports an optional subtitle to show the current selection path.
///
/// Aesthetics:
/// - Clean, rounded rectangle (cornerRadius 10).
/// - Dashed border when inactive, solid and colored when targeted.
/// - Professional typography using small, bold labels.
///
/// Parameters:
/// - title: The primary label for the drop area. Pass an empty string when the surrounding layout
///   already labels the area: with no title and no count the label row is left out entirely.
/// - count: An optional integer to show the number of items already loaded.
/// - subtitle: An optional string to display the current selection or a prompt.
/// - icon: The SF Symbol name to represent the area.
/// - isTargeted: A boolean state tracking if an item is being dragged over.
/// - placeholder: The text shown while `subtitle` is `nil`.
/// - onSelect: A closure triggered when the user taps the area manually.
@available(macOS 11.0, *)
public struct UMUIDropArea: View {
    public let title: String
    public var count: Int? = nil
    public var subtitle: String? = nil
    public let icon: String
    public let isTargeted: Bool
    public var placeholder: String = "Drop items here"
    public let isCompact: Bool
    public let onSelect: () -> Void
    
    @State private var isHovered = false
    
    public init(
        title: String,
        count: Int? = nil,
        subtitle: String? = nil,
        icon: String,
        isTargeted: Bool,
        placeholder: String = "Drop items here",
        isCompact: Bool = false,
        onSelect: @escaping () -> Void
    ) {
        self.title = title
        self.count = count
        self.subtitle = subtitle
        self.icon = icon
        self.isTargeted = isTargeted
        self.placeholder = placeholder
        self.isCompact = isCompact
        self.onSelect = onSelect
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Label and Badge
            if !title.isEmpty || count != nil {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.85))
                    
                    if let count = count {
                        Text("\(count)")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
            }
            
            // Main Interaction Area
            Group {
                if isCompact {
                    HStack(spacing: 8) {
                        if !icon.isEmpty {
                            Image(systemName: icon)
                                .font(.system(size: 14))
                                .foregroundColor(isTargeted ? Color.accentColor : .primary.opacity(0.8))
                        }
                        
                        Text(subtitle ?? placeholder)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundColor(subtitle != nil ? Color.primary : Color.secondary)
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                } else {
                    VStack(spacing: 6) {
                        if !icon.isEmpty {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(isTargeted ? Color.accentColor : .primary.opacity(0.8))
                        }
                        
                        Text(subtitle ?? placeholder)
                            .font(.system(size: 10, weight: .medium))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.horizontal, 8)
                            .foregroundColor(subtitle != nil ? Color.primary : Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                }
            }
            .background(
                isTargeted ?
                    Color.accentColor.opacity(0.18) :
                    (isHovered ? Color.primary.opacity(0.08) : Color.primary.opacity(0.04))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isTargeted ? Color.accentColor : (isHovered ? Color.primary.opacity(0.42) : Color.primary.opacity(0.24)),
                        style: StrokeStyle(
                            lineWidth: 1.25,
                            dash: isTargeted ? [] : [4]
                        )
                    )
            )
            .onHover { hovering in
                isHovered = hovering
            }
            .onTapGesture {
                onSelect()
            }
            .animation(.easeInOut(duration: 0.2), value: isTargeted)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
    }
}
