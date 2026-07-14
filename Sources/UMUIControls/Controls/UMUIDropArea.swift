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
/// - title: The primary label for the drop area.
/// - count: An optional integer to show the number of items already loaded.
/// - subtitle: An optional string to display the current selection or a prompt.
/// - icon: The SF Symbol name to represent the area.
/// - isTargeted: A boolean state tracking if an item is being dragged over.
/// - onSelect: A closure triggered when the user taps the area manually.
@available(macOS 11.0, *)
public struct UMUIDropArea: View {
    public let title: String
    public var count: Int? = nil
    public var subtitle: String? = nil
    public let icon: String
    public let isTargeted: Bool
    public let onSelect: () -> Void
    
    @State private var isHovered = false
    
    public init(
        title: String,
        count: Int? = nil,
        subtitle: String? = nil,
        icon: String,
        isTargeted: Bool,
        onSelect: @escaping () -> Void
    ) {
        self.title = title
        self.count = count
        self.subtitle = subtitle
        self.icon = icon
        self.isTargeted = isTargeted
        self.onSelect = onSelect
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label and Badge
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(.secondary)
                
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            
            // Main Interaction Area
            VStack(spacing: 6) {
                if !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(isTargeted ? Color.accentColor : .secondary)
                }
                
                Text(subtitle ?? "Drop items here")
                    .font(.system(size: 9, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(subtitle != nil ? Color.primary : Color.secondary.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                isTargeted ?
                    Color.accentColor.opacity(0.12) :
                    (isHovered ? Color.primary.opacity(0.06) : Color.primary.opacity(0.03))
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        isTargeted ? Color.accentColor : Color.primary.opacity(0.1),
                        style: StrokeStyle(
                            lineWidth: 1.5,
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
