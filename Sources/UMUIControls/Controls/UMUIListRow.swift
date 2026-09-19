//
//  UMUIListRow.swift
//  UMUIControls
//
//  A selectable navigation row for sidebars and master lists: leading symbol,
//  title, optional subtitle, trailing detail or badge, hover and selection states.
//

import SwiftUI

/// A selectable list row with hover feedback and an accent selection background.
///
/// Usage:
/// ```swift
/// ForEach(events) { event in
///     UMUIListRow(title: event.title,
///                 subtitle: event.date.formatted(),
///                 systemImage: "calendar",
///                 detail: "3",
///                 isSelected: event.id == selection) {
///         selection = event.id
///     }
/// }
/// ```
@available(macOS 11.0, *)
public struct UMUIListRow<Trailing: View>: View {
    /// Row title.
    public let title: String

    /// Optional second line.
    public let subtitle: String?

    /// Optional leading SF Symbol.
    public let systemImage: String?

    /// Whether the row is the current selection.
    public let isSelected: Bool

    /// Called when the row is clicked.
    public let action: () -> Void

    /// Trailing accessory (badge, detail text, status pill…).
    public let trailing: Trailing

    @State private var isHovered = false

    /// Creates a row with a custom trailing accessory.
    public init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
        self.trailing = trailing()
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 12))
                        .frame(width: 16)
                        .foregroundColor(isSelected ? .white : .accentColor)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(isSelected ? .white : .primary)
                    if let subtitle = subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 10))
                            .lineLimit(1)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    }
                }

                Spacer(minLength: 4)

                trailing
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(backgroundColor)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .animation(.easeOut(duration: 0.1), value: isHovered)
    }

    private var backgroundColor: Color {
        if isSelected {
            return .accentColor
        }
        return isHovered ? Color.secondary.opacity(0.12) : Color.clear
    }
}

@available(macOS 11.0, *)
public extension UMUIListRow where Trailing == UMUIListRowDetail {
    /// Creates a row with an optional trailing detail text.
    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        detail: String? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            isSelected: isSelected,
            action: action
        ) {
            UMUIListRowDetail(text: detail)
        }
    }
}

/// The default trailing accessory of `UMUIListRow`: a small monospaced detail, or nothing.
@available(macOS 11.0, *)
public struct UMUIListRowDetail: View {
    public let text: String?

    public init(text: String?) {
        self.text = text
    }

    public var body: some View {
        if let text = text, !text.isEmpty {
            Text(text)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
        }
    }
}

// MARK: - Previews

#if DEBUG
@available(macOS 11.0, *)
struct UMUIListRow_Previews: PreviewProvider {
    struct TestWrapper: View {
        @State private var selection = 1

        var body: some View {
            VStack(spacing: 2) {
                ForEach(0 ..< 4, id: \.self) { i in
                    UMUIListRow(title: "Event \(i + 1)",
                                subtitle: "19 Sep 2026",
                                systemImage: "calendar",
                                detail: "\(i * 2)",
                                isSelected: selection == i) {
                        selection = i
                    }
                }
            }
            .padding(10)
            .frame(width: 260)
        }
    }

    static var previews: some View {
        TestWrapper()
    }
}
#endif
